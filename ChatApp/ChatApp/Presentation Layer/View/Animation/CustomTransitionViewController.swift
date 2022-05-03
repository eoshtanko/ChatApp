//
//  CustomTransitionViewController.swift
//  ChatApp
//
//  Created by Екатерина on 03.05.2022.
//

import UIKit

// Реализация такого CustomTransition не требовалась, но я столкнулась с проблемой,
// описание которой (если вдруг Вам интересно. Читать необязательно) под классом...
class CustomTransitionViewController: NSObject, UIViewControllerAnimatedTransitioning {
    
    var isPushing: Bool = false
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return Const.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
        let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
        
        guard let fromVC = fromVC, let toVC = toVC else {
            return
        }
        
        if isPushing {
            animatePush(using: transitionContext, fromVC: fromVC, toVC: toVC)
        } else {
            animatePop(using: transitionContext, fromVC: fromVC, toVC: toVC)
        }
    }
    
    func animatePush(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        let finalFrame = transitionContext.finalFrame(for: toVC)
        toVC.view.frame = finalFrame.offsetBy(dx: finalFrame.width, dy: Const.offsetValueForY)
        transitionContext.containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        
        UIView.animate( withDuration: transitionDuration(using: transitionContext),
                        animations: { toVC.view.frame = finalFrame },
                        completion: { _ in transitionContext.completeTransition(true) })
    }
    
    func animatePop(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        let initialFrame = transitionContext.initialFrame(for: fromVC)
        let offsetRect = initialFrame.offsetBy(dx: initialFrame.width, dy: Const.offsetValueForY)
        transitionContext.containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        
        UIView.animate( withDuration: transitionDuration(using: transitionContext),
                        animations: { fromVC.view.frame = offsetRect },
                        completion: { _ in transitionContext.completeTransition(true) })
    }
    
    private enum Const {
        static let transitionDuration = 0.25
        static let offsetValueForY: CGFloat = 55
    }
}

/*
 Цель: сделать так, чтобы любое касание экрана приводило к тому, что из области касания (визуально из-под пальца) начинали бы появляться гербы
 Проблема:
 Я сделала UITapGestureRecognizer. Добавила в него #selector(tapAction) (в AppDelegate)
 Как только я запускаю приложение, анимация работает нормально (она длится 1 секунду. Все хорошо)
 Через какое-то время, после того как я похожу по экранчикам, что-то поделаю, время ее жизни сокращается (она длится, скажем, 0.5 сек)
 Еще через какое-то время, она начинает буквально мигать (появляется и тут же исчезает). Скажем, она работает 0.1 сек.
 Еще через какое-то время, она вовсе не появляется
 (хотя дебагер в tapAction заходит.Просто она не успевает запуститься за секунду.
 Если прерывать анимацию не через секунду, а через, скажем, минуту ее можно увидеть)
 
 Причем, анимация со временем не "восстанавливается".
 То есть, если она начала тормозить (не успевать запускаться), то это не пройдет.
 Нужно заново запускать приложение
 
 Далее я заметила, что анимацию "портит" лишь переход на один контроллер, на экран переписки. Если я хожу по
 другим экранам, но в переписку не захожу, то все ок.
 Причем проблемы с анимацией создает именно переход на контроллер переписки.
 Можно перейти на экран переписки (даже первый переход немного уменьшит жизнь анимации)
 и находится на экране сколь угодно долго без проблем.
 Но новое его открытие снова уменьшит жизнь анимации.
 
 Когда я заметила, что анимацию "портит" лишь переход на один контроллер, на экран переписки.
 Я последовательно закомментировала составляющие этого контроллера и нашла причину проблемы.
 Вся беда была из-за кусочка кода
 override var inputAccessoryView: UIView?, начинающегося на 13 строке
 ConversationViewController + SendMessageMethods.swift
 (ChatApp/Presentation Layer/Controller/Conversation/ConversationViewController + SendMessageMethods.swift)
 (Тут я настраиваю кастомные input view)
 Если его закомментировать, все работает
 Далее я закомментировала все настройки этой вьюшки, все, что в ней было, и проблема никуда не ушла.
 
 => Каждое появление(открытие) input view при системном переходе портит анимацию. Кастомный переход проблему решает.
 */
