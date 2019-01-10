//
//  MealDockListViewController.swift
//  MealDock
//
//  Created by Wataru Suzuki 2018/10/02.
//  Copyright © 2018年 WataruSuzuki. All rights reserved.
//

import UIKit
import MaterialComponents.MaterialCollections
import MaterialComponents.MaterialButtons_ColorThemer
import TinyConstraints
import PopMenu
#if canImport(FloatingPanel)
import FloatingPanel
#endif

class MealDockListViewController: UITableViewController,
    //FloatingPanelControllerDelegate,
    DZNEmptyDataSetSource, DZNEmptyDataSetDelegate
{
    let rowHeight = 66
    let fab = MDCFloatingButton()
    let customCellIdentifier = String(describing: StrikethroughTableViewCell.self)
    #if canImport(FloatingPanel)
    let floatingPanel = FloatingPanelController()
    #endif
    var harvests = [[Harvest]]()
    var checkedItems = [String : Harvest]()
    var mediumAdView: UIView?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(fab)
        updateFabHidden(state: true)

        #if canImport(FloatingPanel)
        floatingPanel.delegate = self
        #endif

        self.tableView.registerCustomCell(customCellIdentifier)
        self.tableView.rowHeight = CGFloat(integerLiteral: rowHeight)
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        // A little trick for removing the cell separators
        self.tableView.tableFooterView = UIView()
        
        let colorScheme = MDCSemanticColorScheme()
        colorScheme.primaryColor = view.tintColor
        colorScheme.primaryColorVariant = view.tintColor
        colorScheme.secondaryColor = colorScheme.primaryColor
        
        MDCFloatingButtonColorThemer.applySemanticColorScheme(colorScheme, to: fab)
        if let user = FirebaseService.shared.currentUser, !user.isPurchased, mediumAdView == nil {
            mediumAdView = PurchaseService.shared.mediumSizeBanner(unitId: "your_banner_unit_id", rootViewController: self)
            view.addSubview(mediumAdView!)
        }
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        DispatchQueue.main.async {
            self.layout(fab: self.fab)
            self.mediumAdView?.centerXToSuperview()
            self.mediumAdView?.autoPinEdge(.bottom, to: .top, of: self.tabBarController!.tabBar)
        }
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return harvests.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return harvests[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return tableViewCustomCell(tableView, cellForRowAt: indexPath, harvests: harvests)
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if 0 < harvests[section].count {
            if let harvestSection = Harvest.Section(rawValue: section) {
                return harvestSection.emoji()
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if 0 < harvests[section].count {
            if let user = FirebaseService.shared.currentUser, !user.isPurchased {
                return PurchaseService.shared.bannerView(unitId: "your_banner_unit_id", rootViewController: self)
            }
        }
        return nil
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if 0 < harvests[section].count {
            if let user = FirebaseService.shared.currentUser, !user.isPurchased {
                return 50
            }
        }
        return 0
    }
    
    private func tableViewCustomCell(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, harvests: [[Harvest]]) -> StrikethroughTableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: customCellIdentifier, for: indexPath) as! StrikethroughTableViewCell
        
        // Configure the cell...
        cell.selectionStyle = .none
        
        let harvest = harvests[indexPath.section][indexPath.row]
        cell.textLabel?.text = harvest.name.foodName
        
        let placeHolderImage = UIImage(named: "baseline_help_black_48pt")!.withRenderingMode(.alwaysOriginal).resize(size: CGSize(width: rowHeight, height: rowHeight))
        cell.imageView?.image = placeHolderImage
        
        cell.imageView?.contentMode = .scaleAspectFit
        if harvest.imageUrl.isEmpty {
            cell.imageView?.image = placeHolderImage
        } else {
            cell.imageView?.setImageByAlamofire(with: URL(string: harvest.imageUrl)!)
        }
                
        return cell
    }
    
    func updateCheckedItems(harvest: Harvest) {
        if harvest.count > 0 {
            checkedItems.updateValue(harvest, forKey: harvest.name)
        } else {
            checkedItems.removeValue(forKey: harvest.name)
        }
        updateFabHidden(state: 0 == checkedItems.count)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    // MARK: DZNEmptyDataSetSource

    func verticalOffset(forEmptyDataSet scrollView: UIScrollView!) -> CGFloat {
        return -100.0
    }
    
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "no_foods".localized)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        return NSAttributedString(string: "msg_add_foods".localized)
    }
    
    func buttonTitle(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> NSAttributedString! {
        if let _ =  FirebaseService.shared.currentUser {
            return NSAttributedString()
        } else {
            return NSAttributedString(string: "signIn".localized)
        }
    }
    
    func emptyDataSet(_ scrollView: UIScrollView!, didTap button: UIButton!) {
        guard FirebaseService.shared.currentUser == nil else { return }
        FirebaseService.shared.requestAuthUI()
    }
    
    func emptyDataSetWillAppear(_ scrollView: UIScrollView!) {
        mediumAdView?.isHidden = false
    }
    
    func emptyDataSetWillDisappear(_ scrollView: UIScrollView!) {
        mediumAdView?.isHidden = true
    }

    func onFabTapped() {
        updateFabHidden(state: true)
        checkedItems.removeAll()
    }
    
    func updateFabHidden(state: Bool) {
        fab.isHidden = state
    }
    
    private func presentFabMenus() {
        let plane = PopMenuDefaultAction(title: "share".localized, image: UIImage(named: "paper_plane")?.withRenderingMode(.alwaysTemplate)) { (action) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.onTapPlane()
            }
        }
        
        let undo = PopMenuDefaultAction(title: "undo".localized, image: UIImage(named: "baseline_undo_black_36pt")?.withRenderingMode(.alwaysTemplate)) { (action) in
            self.onTapUndo()
        }
        
        let delete = PopMenuDefaultAction(title: "delete".localized, image: UIImage(named: "trash_people")?.withRenderingMode(.alwaysTemplate), color: UIColor.red) { (action) in
            self.onTapDelete()
        }
        
        let popMenu = PopMenuViewController(sourceView: fab, actions: [plane, undo, delete])
        popMenu.appearance.popMenuBackgroundStyle = .blurred(.light)
        present(popMenu, animated: true, completion: nil)
    }
    
    func onTapPlane() {
        //Please override it
    }
    
    func onTapUndo() {
        checkedItems.removeAll()
        tableView.reloadData()
        //Please override it
    }
    
    func onTapDelete() {
        //Please override it
    }
    
    @objc func onFabLongPressed(sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            fab.isHidden = true
            presentFabMenus()
        default:
            break
        }
    }
}
