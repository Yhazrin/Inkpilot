import Foundation

/// Real `SuggestionService` that proxies to the local FastAPI backend
/// (which in turn calls MiniMax). The iPad never holds the LLM key —
/// the Mac does.
///
/// On any transport / parse / upstream failure we fall back to a
/// deterministic, well-formed `AISuggestionResponse` so the UI never
/// shows an empty ghost card.
final class NetworkSuggestionService: SuggestionService {

    private let baseURL: URL
    private let session: URLSession

    init(baseURL: URL = BackendConfig.baseURL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }

    func generateSuggestion(context: CanvasContext) async throws -> AISuggestionResponse {
        let url = baseURL.appendingPathComponent("api/inkpilot/suggestions")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body = SuggestRequestBody(
            context_text: context.inkText,
            anchor_hint: nil,
            mode_hint: nil,
            canvasContext: CanvasContextPayload(
                locale: context.locale,
                ink_text: context.inkText,
                prompt_text: context.promptText,
                selected_object: context.selectedObjectSummary,
                canvas_objects: context.canvasObjectSummaries.map {
                    ["type": $0.type, "title": $0.title]
                }
            )
        )
        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        do {
            let (data, response) = try await session.data(for: request)
            guard let http = response as? HTTPURLResponse else {
                return Self.fallback(reason: "non-http response")
            }
            guard (200..<300).contains(http.statusCode) else {
                let snippet = String(data: data, encoding: .utf8)?.prefix(160) ?? ""
                return Self.fallback(reason: "http \(http.statusCode): \(snippet)")
            }
            let decoded = try JSONDecoder().decode(SuggestionResponseDTO.self, from: data)
            return decoded.toDomain()
        } catch {
            return Self.fallback(reason: "transport: \(error.localizedDescription)")
        }
    }

    // MARK: - Local fallback

    /// Used when the backend is unreachable, the key is missing, or the
    /// upstream returned something we can't parse. Always returns a
    /// well-formed `AISuggestionResponse` so the UI keeps moving.
    private static func fallback(reason: String) -> AISuggestionResponse {
        #if DEBUG
        print("[NetworkSuggestionService] fallback — \(reason)")
        #endif
        return AISuggestionResponse(
            mode: .structure,
            title: String(localized: "fallback.title"),
            items: [
                AISuggestionItem(
                    id: UUID(),
                    type: .aiCard,
                    title: String(localized: "fallback.item1.title"),
                    content: String(localized: "fallback.item1.content")
                ),
                AISuggestionItem(
                    id: UUID(),
                    type: .stickyNote,
                    title: String(localized: "fallback.item2.title"),
                    content: String(localized: "fallback.item2.content")
                ),
                AISuggestionItem(
                    id: UUID(),
                    type: .textBox,
                    title: String(localized: "fallback.item3.title"),
                    content: String(localized: "fallback.item3.content")
                ),
            ]
        )
    }
}

// MARK: - Wire types (mirror Backend/server.py)

private struct SuggestRequestBody: Encodable {
    let context_text: String
    let anchor_hint: String?
    let mode_hint: String?
    let canvasContext: CanvasContextPayload?
}

private struct CanvasContextPayload: Encodable {
    let locale: String
    let ink_text: String
    let prompt_text: String
    let selected_object: String?
    let canvas_objects: [[String: String]]
}

private struct SuggestionItemDTO: Decodable {
    let id: String
    let type: String
    let title: String
    let content: String
}

private struct SuggestionResponseDTO: Decodable {
    let mode: String
    let title: String
    let items: [SuggestionItemDTO]

    func toDomain() -> AISuggestionResponse {
        let mappedMode = SuggestionMode(rawValue: mode) ?? .structure
        let mappedItems: [AISuggestionItem] = items.enumerated().map { idx, item in
            AISuggestionItem(
                id: UUID(),
                type: Self.mapType(item.type),
                title: item.title,
                content: item.content
            )
        }
        return AISuggestionResponse(mode: mappedMode, title: title, items: mappedItems)
    }

    private static func mapType(_ raw: String) -> CanvasObjectType {
        switch raw {
        case "aiCard":     return .aiCard
        case "textBox":    return .textBox
        case "stickyNote": return .stickyNote
        case "bubble":     return .bubble
        case "shape":      return .shape
        case "connector":  return .connector
        case "image":      return .image
        case "file":       return .file
        default:           return .aiCard
        }
    }
}
