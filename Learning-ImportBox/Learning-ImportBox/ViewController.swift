//
//  ViewController.swift
//  Learning-ImportBox
//
//  Created by Tiến Việt Trịnh on 12/08/2023.
//

import UIKit
import BoxSDK
import AuthenticationServices
import AuthenticationServices

class ViewController: UIViewController, ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        self.view.window ?? ASPresentationAnchor()
    }
    
    
    //MARK: - Properties
    let sdk = BoxSDK(clientId: "svnd1wuzvise4hggaf5wapqdz4ixxnd7",
                     clientSecret: "mJTYcV07W9hCJg4D3xAUcns59piYaaFU")
    var client: BoxClient!
    
    //MARK: - UIComponent
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log In", for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLoginhButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log Out", for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(handleLogoutButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var listFileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("List file", for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(listFileButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download", for: .normal)
        button.tintColor = .black
        button.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        return button
    }()
    
    @objc func handleLoginhButtonTapped() {
        
        sdk.getOAuth2Client(tokenStore: KeychainTokenStore(), context: self) { result in
            switch result {
            case let .success(client):
                self.client = client
                
                self.client.users.getCurrent(fields: ["name", "login"]) { (result: Result<User, BoxSDKError>) in
                    switch result {
                    case .success(let user):
                        print("DEBUG: \(String(describing: user.name)) and \(String(describing: user.login))")
                    case .failure(let error) :
                        print("DEBUG: \(error.localizedDescription)")
                    }
                }
                
            case let .failure(error):
                print("DEBUG: \(error.message) ẹc eee")
            }
        }
        
        //tienviet153153@gmail.com
        //mdgarp49

    }
    
    @objc func handleLogoutButtonTapped() {
        if client == nil {return}
        client.destroy() { result in
            guard case .success = result else {
                print("Tokens could not be revoked!")
                return
            }

            print("Tokens were successfully revoked")
        }
    }
    
    @objc func listFileButtonTapped() {
        searchFileMP3AndMP4()
    }
    
    @objc func downloadButtonTapped() {
        downloadFile(fileId: "1278631960261")
    }
    
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        
    }
    
    func configureUI() {
        view.backgroundColor = .red
        view.addSubview(loginButton)
        view.addSubview(logoutButton)
        view.addSubview(listFileButton)
        view.addSubview(downloadButton)
        
        loginButton.frame = .init(x: 100, y: 200, width: 100, height: 50)
        logoutButton.frame = .init(x: 100, y: 300, width: 100, height: 50)
        listFileButton.frame = .init(x: 100, y: 400, width: 100, height: 50)
        downloadButton.frame = .init(x: 100, y: 500, width: 100, height: 50)
    }
    
}

//MARK: - Method
extension ViewController {
    
    //MARK: - Helpers
    func searchFileMP3AndMP4() {
        if client == nil {return}
 
        client.search.query(query: "mov OR png OR HEIC", fileExtensions: ["png, HEIC, mov"]).next { result in
            switch result {
            case .success(let page):
                print("DEBUG: \(page.entries.count)")
                for item in page.entries {
                       switch item {
                       case let .file(file):
                           print("DEBUG: File \(file.name) (ID: \(file.id))")
                       case let .folder(folder):
                           print("DEBUG: Folder \(folder.name) (ID: \(folder.id))")
                       case let .webLink(webLink):
                           print("DEBUG: Web Link \(webLink.name) (ID: \(webLink.id))")
                       }
                   }
            case .failure(let error) :
                print("DEBUG: \(error.message)")
            }
        }
    }
    
    func listFile() {
        let iterator = client.folders.listItems(folderId: "0", marker: "ile_extensions=png" ,sort: .name, direction: .ascending)
        iterator.next { results in
            switch results {
            case let .success(page):
                for item in page.entries {
                    switch item {
                    case let .file(file):
                        print("DEBUG: File \(String(describing: file.name)) (ID: \(file.id)) is in the folder")
                    case let .folder(folder):
                        print("DEBUG: Subfolder \(String(describing: folder.name)) (ID: \(folder.id)) is in the folder")
                    case let .webLink(webLink):
                        print("DEBUG: Web link \(String(describing: webLink.name)) (ID: \(webLink.id)) is in the folder")
                    }
                }

            case let .failure(error):
                print("DEBUG: \(error.localizedDescription)")
            }
        }

    }
    
    func downloadFile(fileId: String) {
        if client == nil {return}
        let url = URL.videoEditorFolder()?.appendingPathComponent("file.heic")
        
        print("DEBUG: \(url)")

        let task: BoxDownloadTask = client.files.download(fileId: fileId, destinationURL: url!) { (result: Result<Void, BoxSDKError>) in
            switch result {
            case .success(let success):
                print("DEBUG: File downloaded successfully")
            case .failure(let failure):
                print("DEBUG: \(failure.message)")
            }
           
    }

        // To cancel download
//        if someConditionIsSatisfied {
//            task.cancel()
//        }
    }

    
    //MARK: - Selectors
    
}


