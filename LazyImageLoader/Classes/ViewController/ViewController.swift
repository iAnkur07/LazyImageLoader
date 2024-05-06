//
//  ViewController.swift
//  LazyImageLoader
//
//  Created by Ankur on 04/05/24.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    let perPageCount = 100
    var lastCount = 100
    var page = 0

    var data = [ImageModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        getImages()
    }
    
}

// MARK: - UICollectionView
extension ViewController: UICollectionViewDelegate,
                            UICollectionViewDataSource {
    func setupCollectionView() {
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.register(UINib(nibName: ImagesCell.cellId, bundle: nil), forCellWithReuseIdentifier: ImagesCell.cellId)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 2
        layout.minimumInteritemSpacing = 0
        
        let width = Int(UIScreen.main.bounds.width / 3)
        let height = Int(width + 40)
        layout.itemSize = CGSize(width: CGFloat(width), height: CGFloat(height))
        
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return data.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImagesCell.cellId, for: indexPath) as? ImagesCell else {
            return UICollectionViewCell()
        }
        
        let item = data[indexPath.item]
        cell.postImageView.image = nil
        cell.postImageView.tag = indexPath.item
        cell.postImageView.setImageFrom(url: item.url, index: indexPath.item) { image, index in
            let cell = collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ImagesCell
            cell?.postImageView.image = image
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if page != 0 &&
            indexPath.item == data.count - 9 &&
            data.count >= perPageCount {
            self.getImages()
        }
    }
    
}

// MARK: - Apis
extension ViewController {
    func getImages() {
        NetworkManager.shared.getImages(lastCount: lastCount) { result in
            switch result {
            case .success(let data):
                if self.page == 0 {
                    self.data = data
                } else {
                    for item in data {
                        if !self.data.contains(where: { $0.id == item.id }) {
                            self.data.append(item)
                        }
                    }
                }
                
                if data.count == 0 {
                    self.page = 0
                } else {
                    self.page += 1
                    self.lastCount += self.perPageCount
                }
                
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
                self.alert(message: error.localizedDescription)
            }
        }
    }
    
    private func alert(message: String) {
        let alertController = UIAlertController(title: "Error Message", message: message, preferredStyle: .alert)
        let okay = UIAlertAction(title: "Okay", style: .default)
        alertController.addAction(okay)
        self.present(alertController, animated: true)
    }
}
