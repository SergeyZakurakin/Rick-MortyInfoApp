//
//  ViewController.swift
//  RickMortyApiApp
//
//  Created by Sergey Zakurakin on 11/05/2024.
//

import UIKit


final class ViewController: UIViewController {
    
    
    @IBOutlet var characterImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    
    private let initualUrl = "https://rickandmortyapi.com/api/character"
    private var nextURL: String?
    private var rickMorty: RickMorty?
    private var currentIndex = 0
    private let networkManager = NetworkManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchData(from: initualUrl)
    }
    
    
    @IBAction func nextButtonPressed() {
        
        if let rickMorty = rickMorty {
            currentIndex += 1
            if currentIndex < rickMorty.results.count {
                updateUI(with: rickMorty.results[currentIndex])
            } else if let nextPage = nextURL {
                fetchData(from: nextPage)
            }
        }
    }
    
    
    private func fetchData(from urlString: String) {
        guard let urlString = URL(string: urlString) else { return }
        networkManager.fetchData(from: urlString) { [weak self] result in
            guard let self else {return}
            switch result {
            case .success(let rickM):
                rickMorty = rickM
                nextURL = rickM.info.next
                currentIndex = 0
                if let firstCharacter = rickM.results.first {
                    updateUI(with: firstCharacter)
                }
            case .failure(let error):
                print(error)
            }
        }
    }

    
    private func fetchImage(from urlString: String) {
        guard let urlString = URL(string: urlString) else { return }
        networkManager.fetchImage(from: urlString) { [unowned self] result in
            switch result {
            case .success(let ImageData):
                characterImageView.image = UIImage(data: ImageData)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func updateUI(with character: CharacterResult) {
        nameLabel.text = character.name
        fetchImage(from: character.image)
        
    }
    
}
