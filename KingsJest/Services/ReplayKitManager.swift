//
//  ReplayKitManager.swift
//  KingsJest
//
//  Created by Luiz Seibel on 04/04/25.
//

import SwiftUI
import ReplayKit

/// Erros personalizados para auxiliar na identificação de falhas
enum ReplayKitError: Error, LocalizedError {
    case notAvailable
    case failedToStart
    case failedToStop

    var errorDescription: String? {
        switch self {
        case .notAvailable:
            return "A gravação de tela não está disponível no momento."
        case .failedToStart:
            return "Falha ao iniciar a gravação."
        case .failedToStop:
            return "Falha ao encerrar a gravação."
        }
    }
}

/// Singleton responsável por gerenciar gravações usando o ReplayKit
final class ReplayKitManager: NSObject {

    static let shared = ReplayKitManager()
    private let recorder = RPScreenRecorder.shared()

    private override init() {
        super.init()
    }

    // 🔒 Propriedades armazenadas para exibir o preview depois
    private var previewViewController: RPPreviewViewController?
    private var presenter: UIViewController?

    func startRecording(microphoneEnabled: Bool = true,
                        completion: @escaping (Error?) -> Void) {
        guard recorder.isAvailable else {
            completion(ReplayKitError.notAvailable)
            return
        }

        recorder.isMicrophoneEnabled = microphoneEnabled
        recorder.startRecording { error in
            completion(error)
        }
    }

    func stopRecording(presenter: UIViewController?,
                       completion: @escaping (Error?) -> Void) {
        recorder.stopRecording { [weak self] previewViewController, error in
            guard let self = self else { return }

            if let error = error {
                completion(error)
                return
            }

            // Salva os valores para uso posterior
            self.previewViewController = previewViewController
            self.presenter = presenter

            completion(nil)
        }
    }

    /// Exibe a tela de preview (com opção de compartilhar o vídeo)
    func showPreview() {
        guard let previewVC = previewViewController,
              let presenter = presenter else {
            print("Preview ou presenter não disponíveis.")
            return
        }

        previewVC.previewControllerDelegate = self
        presenter.present(previewVC, animated: true, completion: nil)
        
        // Limpa os armazenamentos para evitar reuso indevido
        self.previewViewController = nil
        self.presenter = nil
    }
}

// MARK: - RPPreviewViewControllerDelegate
extension ReplayKitManager: RPPreviewViewControllerDelegate {
    /// Método de callback chamado quando o usuário termina de interagir com o preview.
    public func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        previewController.dismiss(animated: true)
    }
}


extension UIApplication {
    /// Retorna o rootViewController da primeira window em foreground,
    /// que estará apto a apresentar novas telas.
    func rootViewController() -> UIViewController? {
        guard let windowScene = connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene,
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController
    }
}

import AVFoundation

final class PermissionsManager {
    static func solicitarPermissaoMicrofone() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            if granted {
                print("Permissão ao microfone concedida.")
            } else {
                print("Permissão ao microfone negada.")
            }
        }
    }
}
