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
        let url = baseURL.appendingPathComponent("suggest")
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = 30
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let body = SuggestRequestBody(
            context_text: context.inkText,
            anchor_hint: nil,
            mode_hint: nil
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
            title: "Suggested next step",
            items: [
                AISuggestionItem(
                    id: UUID(),
                    type: .aiCard,
                    title: "Backend offline",
                    content: "Start uvicorn on the Mac and update BackendConfig.baseURL."
                ),
                AISuggestionItem(
                    id: UUID(),
                    type: .stickyNote,
                    title: "Quick check",
                    content: "Try `curl http://<mac>:8000/health` from terminal."
                ),
                AISuggestionItem(
                    id: UUID(),
                    type: .textBox,
                    title: "LAN setup",
                    content: "Info.plist already allows local networking; URL is in BackendConfig.swift."
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
