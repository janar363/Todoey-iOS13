
import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var categoryArray: Results<Category>?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCategories()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let navBar = self.navigationController?.navigationBar else {fatalError("Navbar does not exist")}
        
        let customAppearance = UINavigationBarAppearance()
        customAppearance.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.7568627451, blue: 0.9725490196, alpha: 1)
        customAppearance.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor : #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)]
        
        navBar.backgroundColor = #colorLiteral(red: 0.2980392157, green: 0.7568627451, blue: 0.9725490196, alpha: 1)
        navBar.scrollEdgeAppearance = customAppearance
        navBar.standardAppearance = customAppearance
        
    }
    
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        var textField = UITextField()
        
        let alert = UIAlertController(title: "New Category", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Add Category", style: .default) { alertAction in
            
            if textField.text != "" {
                let newCategory = Category()
                newCategory.name = textField.text!
                newCategory.cellColor = UIColor.randomFlat().hexValue()
                
                self.save(category: newCategory)
            
            } else {
                print("Type something...")
            }
        }
        
        alert.addAction(action)
        alert.addTextField { alertTextField in
            textField = alertTextField
        }
        
        present(alert, animated: true, completion: nil)
    }
    
    
    //MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        cell.textLabel?.text = categoryArray?[indexPath.row].name ?? "No categories added yet"
        
        cell.backgroundColor = UIColor(hexString: categoryArray?[indexPath.row].cellColor ?? "4CC1F8")
        
        cell.textLabel?.textColor = ContrastColorOf(cell.backgroundColor!, returnFlat: true)
        
        return cell
    }
    //MARK: - Table view delegate methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "goToItems", sender: self)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVc = segue.destination as! ToDoListViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVc.category = categoryArray?[indexPath.row]
        }
    }
    
    //MARK: - Data manipulation methods
    
    func save(category: Category){
        do{
            try realm.write({
                realm.add(category)
            })
        } catch {
            print("Could not save category due to \(error)")
        }
        tableView.reloadData()
    }
    
    func loadCategories(){
        
        categoryArray = realm.objects(Category.self)
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let currentCategory = self.categoryArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(currentCategory)
                    }
            } catch {
                print("cannot delete Category due to \(error)")
            }
        }
    }
}
