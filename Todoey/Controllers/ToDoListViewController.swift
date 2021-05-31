import UIKit
import RealmSwift
import ChameleonFramework

class ToDoListViewController: SwipeTableViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    var itemArrar: Results<Item>!
    let realm = try! Realm()
    
    var category: Category? {
        didSet{
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        if let hexColor = category?.cellColor {
            
            guard let navBar = self.navigationController?.navigationBar else {fatalError("navbar does not exist")}
            
            let navBarColor = UIColor(hexString: hexColor)
            
            let customAppearence = UINavigationBarAppearance()
            customAppearence.backgroundColor = navBarColor
            customAppearence.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : ContrastColorOf(navBarColor!, returnFlat: true)]
            
            navBar.backgroundColor = navBarColor
            navBar.scrollEdgeAppearance = customAppearence
            navBar.standardAppearance = customAppearence
            navBar.tintColor = ContrastColorOf(navBarColor!, returnFlat: true)
            searchBar.backgroundColor = navBarColor
            searchBar.tintColor = ContrastColorOf(navBarColor!, returnFlat: true)
            searchBar.placeholder = "search"
            
            title = category?.name
        }
    }
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        // creating an alert when add button is pressed
        let alert = UIAlertController(title: "New Item", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Item", style: .default) { alertAction in
            // what happens when add item button is clicked
            
            if textField.text != ""{
                
                if let currentCategory = self.category {
                    do {
                        try self.realm.write({
                            let newItem = Item()
                            newItem.title = textField.text!
                            newItem.dateAdded = Date()
                            currentCategory.items.append(newItem)
                        })
                    } catch {
                        print("Error saving new items due to \(error)")
                    }
                    
                }
                    
                
                self.tableView.reloadData()
                
            } else {
                print("Please enter an item")
            }
            
        }
        
        alert.addTextField { alertTextField in
            alertTextField.placeholder = "New Item"
            textField = alertTextField
        }
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
    // TableView data source methods
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemArrar?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let item = itemArrar?[indexPath.row] {
            cell.textLabel?.text = item.title
            cell.accessoryType = item.done ? .checkmark : .none
            
            let color = UIColor(hexString: (category?.cellColor)!)
            cell.backgroundColor = color?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(itemArrar!.count))
            cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
            
        } else {
            cell.textLabel?.text = "No Items added"
        }
        
        
        return cell
    }
    
    // tableview delegate methods
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = itemArrar?[indexPath.row] {
            do {
                try realm.write({
                    item.done = !item.done
                })
            } catch {
                print("cannot update data due to \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // data manipulation
    
    func loadItems() {
        
        itemArrar = category?.items.sorted(byKeyPath: "dateAdded", ascending: true)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let currentItem = itemArrar?[indexPath.row] {
            do{
                try realm.write({
                    self.realm.delete(currentItem)
                })
            } catch {
                print("Cannot delete Item due to \(error)")
            }
        }
    }
}
 

//MARK: - Search bar delgate methods

extension ToDoListViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // querying the data base
        itemArrar = itemArrar.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateAdded", ascending: true)
        
        tableView.reloadData()
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            loadItems()

            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }

        }
    }
}
