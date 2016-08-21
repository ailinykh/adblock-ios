
import UIKit

class InstructionView: UIViewController
{
    @IBOutlet var topConstraint     : NSLayoutConstraint?
    @IBOutlet var widthConstraint   : NSLayoutConstraint?
    @IBOutlet var heightConstraint  : NSLayoutConstraint?

    @IBOutlet var doneButton : UIButton?
    @IBOutlet var imageView : UIImageView?
    @IBOutlet var descriptionLabel : UILabel?
    
    var pageIndex       : Int = 0
    var pageImageName   : String = ""
    var pageText        : NSAttributedString = NSAttributedString()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        // iPhone 4S
        if(UIScreen.mainScreen().bounds.size.height <= 480.0)
        {
            topConstraint?.constant = 10.0
            widthConstraint?.constant = 240.0
            heightConstraint?.constant = 280.0
        }
        
        if (UIDevice.currentDevice().userInterfaceIdiom == UIUserInterfaceIdiom.Pad)
        {
            topConstraint?.constant = 80.0
        }
        
        doneButton?.hidden = true
        doneButton?.alpha = 0.0
        doneButton?.layer.cornerRadius = 8.0
        doneButton?.setTitle("Start".localized, forState: UIControlState.Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        imageView?.image = UIImage(named: pageImageName)
        descriptionLabel!.attributedText = pageText
        
        self.performSelector("update", withObject: nil, afterDelay: 0.3)
        
        if(pageIndex == 2)
        {
            self.performSelector("showDoneButton", withObject: nil, afterDelay: 0.7)
        }
    }
    
    func update() {
        imageView?.image = UIImage(named: pageImageName)
        descriptionLabel!.attributedText = pageText
    }
    
    func showDoneButton()
    {
        doneButton?.hidden = (pageIndex != 2)
        if(doneButton?.hidden == false)
        {
            UIView.animateWithDuration(0.3, animations: { () -> Void in
                self.doneButton?.alpha = 1.0
            })
        }
    }
    
    @IBAction func doneAction()
    {
        self.parentViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
