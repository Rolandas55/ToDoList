//
//  DetailViewController.swift
//  ToDoList
//
//  Created by kraujalis.rolandas on 05/11/2023.
//

import UIKit

class DetailViewController: UIViewController {
    
    var toDoTitle = ""
    var toDoSubtitle = ""
    var todoCompleted = false

    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()

        // Do any additional setup after loading the view.
    }
    
    private func setupView() {
        let infoView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        let title = UILabel()
        let text = UILabel()
        let completion = UILabel()
        
        title.translatesAutoresizingMaskIntoConstraints = false
        text.translatesAutoresizingMaskIntoConstraints = false
        completion.translatesAutoresizingMaskIntoConstraints = false
        
        title.textColor = UIColor.label
        title.font = UIFont(name: "GillSans", size: 22)
        
        title.font = UIFont(name: "GillSans", size: 20)
        
        text.textColor = UIColor.label
        text.font = UIFont(name: "GillSans", size: 16)
        
        infoView.addSubview(title)
        infoView.addSubview(text)
        infoView.addSubview(completion)
        
        title.centerYAnchor.constraint(equalTo: infoView.topAnchor, constant: 100).isActive = true
        title.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        
        text.topAnchor.constraint(equalTo: title.bottomAnchor, constant: 50).isActive = true
        text.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        text.widthAnchor.constraint(equalToConstant: 300).isActive = true
        
        completion.centerXAnchor.constraint(equalTo: infoView.centerXAnchor).isActive = true
        completion.centerYAnchor.constraint(equalTo: infoView.bottomAnchor, constant: -100).isActive = true

        view.backgroundColor = UIColor.secondarySystemBackground
        if todoCompleted {
            completion.textColor = UIColor.green
            completion.text = "task is completed"
        } else {
            completion.textColor  = UIColor.orange
            completion.text = "task is not completed"
        }
        title.text = toDoTitle
        text.text = toDoSubtitle
        text.numberOfLines = 0
        text.textAlignment = .center
        self.view.addSubview(infoView)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
