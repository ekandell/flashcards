//
//  ViewController.swift
//  final-project
//
//  Created by Shyam Kumar on 11/19/21.
//

import CoreData
import UIKit

fileprivate var entityKey: String = "Flashcard"
fileprivate var termKey: String = "term"
fileprivate var definitionKey: String = "definition"

struct ViewControllerModel {
    var flashcards: [NSManagedObject] = []
    
    var numcards: Int
    
    init(flashcards: [NSManagedObject] = []) {
        self.flashcards = flashcards
        self.numcards = flashcards.count
    }
}

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupView()
        setupConstraints()
        fetchData()
    }
    
    var model: ViewControllerModel = ViewControllerModel() {
        didSet {
            // updateView()
        }
    }
    
    

    var currCard = 0
    
    lazy var cardView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 218/255, green: 1, blue: 179/255, alpha: 0.85)
        view.layer.shadowOffset = CGSize(width: 0, height: 15)

        return view
    }()
    
    var flipButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Flip", for: .normal)
        if #available(iOS 15.0, *) {
            button.setTitleColor(.systemCyan, for: .normal)
        } else {
            button.setTitleColor(.cyan, for: .normal)
        }
        
        return button
    }()
    
    var deleteButton: UIButton = {
        let button = UIButton()
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete", for: .normal)
        if #available(iOS 15.0, *) {
            button.setTitleColor(.systemRed, for: .normal)
        } else {
            button.setTitleColor(.red, for: .normal)
        }
        
        return button
    }()
    
    
    var defText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Use the buttons at the top of the screen to add more flashcards, switch between them, and delete previously made cards"
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    var termText: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to flashcards!"
        label.textAlignment = .center
        return label
    }()
    
    func setupView() {
        view.backgroundColor = UIColor(red: 240/255, green: 240/255, blue: 240/255, alpha: 0.95)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addItem))
        navigationItem.title = "Flashcards"
        
        flipButton.addTarget(self, action: #selector(flipItem), for: .touchUpInside)
        
        deleteButton.addTarget(self, action: #selector(deleteItem), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .fastForward, target: self, action: #selector(nextItem))
        
        cardView.addSubview(termText)
        cardView.addSubview(defText)
        defText.isHidden = true
        view.addSubview(cardView)
        view.addSubview(flipButton)
        view.addSubview(deleteButton)
        
    }
    
    func setupConstraints() {
        cardView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        cardView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        cardView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.85).isActive = true
        cardView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4).isActive = true
        
        termText.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        termText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        termText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        
        defText.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        defText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        defText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7).isActive = true
        
        flipButton.topAnchor.constraint(equalTo: cardView.bottomAnchor, constant: 20).isActive = true
        flipButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        flipButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.6).isActive = true
        flipButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        deleteButton.bottomAnchor.constraint(equalTo: cardView.topAnchor, constant: -20).isActive = true
        deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        deleteButton.widthAnchor.constraint(equalTo: cardView.widthAnchor, multiplier: 0.4).isActive = true
        deleteButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
    
    
    
    @objc func addItem() {
        let alert = UIAlertController(
            title: "New Card",
            message: "Add a term and its definition",
            preferredStyle: .alert
        )
        
        let saveAction = UIAlertAction(title: "Save", style: .default, handler: { [self] action in
            guard let termField = alert.textFields?.first,
                  let termtoSave = termField.text else {
                return
            }
            guard let defField = alert.textFields?.last, let deftoSave = defField.text else {
                return
            }
            
            save(term: termtoSave, def: deftoSave)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        alert.addTextField()
        alert.addTextField()
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    @objc func nextItem() {
        if currCard < model.numcards {
            let nextCard = model.flashcards[currCard]
            termText.text = nextCard.value(forKey: "term") as? String
            defText.text = nextCard.value(forKey: "definition") as? String
            if termText.isHidden {
                flipItem()
            }
            currCard += 1
        } else if model.numcards > 0 {
            currCard = 0
            model.flashcards.shuffle()
            nextItem()
        } else {
            currCard = 0
            termText.text = "Welcome to flashcards!"
            defText.text = "Use the buttons at the top of the screen to add more flashcards, switch between them, and delete previously made cards"
        }
        
    }
    
    @objc func flipItem() {
        if defText.isHidden {
            termText.isHidden = true
            defText.isHidden = false
        } else if termText.isHidden {
            defText.isHidden = true
            termText.isHidden = false
        } else {
            return
        }
    }
    
    @objc func deleteItem() {
        if model.numcards > 0 {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        managedContext.delete(model.flashcards[currCard - 1])
        saveManagedContext()
        fetchData()
        }
//        model.numcards -= 1
//        currCard += 1
//        nextItem()
    }
}




extension ViewController {
    func fetchData() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: entityKey)
        
        do {
            let flashcards = try managedContext.fetch(fetchRequest)
            model.flashcards = flashcards
            model.numcards = flashcards.count
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        nextItem()
    }
    
    func save(term: String, def: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: entityKey, in: managedContext) else { return }
        let flashcard = NSManagedObject(entity: entity, insertInto: managedContext)
        flashcard.setValue(term, forKey: termKey)
        flashcard.setValue(def, forKey: definitionKey)
        
        do {
            try managedContext.save()
            model.flashcards.append(flashcard)
            model.numcards += 1
            currCard = model.numcards - 1
            nextItem()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func saveManagedContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
}
