//
//  ConversationApi.swift
//  ChatApp
//
//  Created by Екатерина on 06.03.2022.
//

import UIKit

class ConversationApi {
    
    static let formatter = DateFormatter()
    
    static func getOnlineConversations() -> [Conversation]{
        ConversationApi.formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return [
            Conversation(name: "Ivan Simonov", message: "What's the algebra homework?🥺", date: NSDate() as Date - 100, online: true, hasUnreadMessages: false, image: UIImage(named: "man1.jpg")),
            Conversation(name: "Alexandr Kozlov", message: "Watch the movie \"Kill the Dragon\". It's very good!", date: NSDate() as Date - 1000, online: true, hasUnreadMessages: true, image: UIImage(named: "man2.jpg")),
            Conversation(name: "Lily Jones", message: "Надо просить позволить свои команды.", date: NSDate() as Date - Const.day, online: true, hasUnreadMessages: false, image: nil),
            Conversation(name: nil, message: "Wake up!!!!", date: nil, online: true, hasUnreadMessages: true, image: nil),
            Conversation(name: "Sophie Williams", message: "Привет! Я с ПИ, мы на одном курсе. Слушай, нам тут разрешили свопаться вариантами по ПАПСу, и мне это было бы интересно, поэтому тебе и пишу.", date: NSDate() as Date - Const.day - 100, online: true, hasUnreadMessages: false, image: UIImage(named: "woman1.jpg")),
            Conversation(name: "Isabella Li", message: nil, date: NSDate() as Date - Const.day - 1000, online: true, hasUnreadMessages: false, image: UIImage(named: "woman2.jpg")),
            Conversation(name: "Ava Anderson", message: "Come out for a walk today! 🌞 The weather is so wonderful there! Birds, spring, grace!", date: ConversationApi.formatter.date(from: "3/3/2022 14:30"), online: true, hasUnreadMessages: false, image: nil),
            Conversation(name: nil, message: "Have you read The Death of Ivan Ilyich? Awesome book!!!", date: ConversationApi.formatter.date(from: "3/3/2022 10:12"), online: true, hasUnreadMessages: true, image: nil),
            Conversation(name: "Jacob Morton", message: "Let's go to the Ludovico Einaudi concert!", date: ConversationApi.formatter.date(from: "1/3/2022 11:12"), online: true, hasUnreadMessages: false, image: UIImage(named: "man3.jpg")),
            Conversation(name: "Jessica Brown", message: "I don't have time to finish my term paper 🤯", date: ConversationApi.formatter.date(from: "1/3/2022 11:11"), online: true, hasUnreadMessages: true, image: UIImage(named: "woman3.jpg")),
            Conversation(name: "Anna Smith", message: nil, date: nil, online: true, hasUnreadMessages: false, image: nil),
            Conversation(name: "Alex Mironov", message: "I didn't like it :(", date: ConversationApi.formatter.date(from: "5/3/2022 10:12"), online: true, hasUnreadMessages: true, image: nil),
            Conversation(name: "Katya Shtanko", message: nil, date: ConversationApi.formatter.date(from: "5/3/2022 10:11"), online: true, hasUnreadMessages: false, image: UIImage(named: "woman4.jpg")),
            Conversation(name: "Alan Ranger", message: nil, date: ConversationApi.formatter.date(from: "27/2/2022 10:10"), online: true, hasUnreadMessages: false, image: nil),
            Conversation(name: "Viktoria Maass", message: "Thank you! 😊", date: ConversationApi.formatter.date(from: "5/1/2022 13:27"), online: true, hasUnreadMessages: false, image: UIImage(named: "woman5.jpg")),
            Conversation(name: "Donald Trump", message: "What's up?", date: ConversationApi.formatter.date(from: "31/12/2021 10:12"), online: true, hasUnreadMessages: true, image: nil)
        ]
    }
    
    static func getOfflineConversations() -> [Conversation]{
        ConversationApi.formatter.dateFormat = "dd/MM/yyyy HH:mm"
        return [
            Conversation(name: "Nikolay Romahkov", message: "I overslept the class... Again.", date: NSDate() as Date - 1000, online: false, hasUnreadMessages: false, image: UIImage(named: "man4.jpg")),
            Conversation(name: "Denis Kizodov", message: "I'm so sorry 😔", date: NSDate() as Date - 2000, online: false, hasUnreadMessages: true, image: UIImage(named: "man5.jpg")),
            Conversation(name: nil, message: nil, date: NSDate() as Date - 3000, online: false, hasUnreadMessages: false, image: nil),
            Conversation(name: "Emily Taylor", message: "That's cute!!! :)", date: NSDate() as Date - Const.day, online: false, hasUnreadMessages: true, image: nil),
            Conversation(name: "Thomas Evans", message: "А как у тебя описана такая функциональность системы как например распределение в стационаре", date: NSDate() as Date - Const.day - 10000, online: false, hasUnreadMessages: false, image: UIImage(named: "man6.jpg")),
            Conversation(name: "Poppy Davies", message: "Чтобы ответить на этот вопрос, придётся заглянуть в прошлую таблицу. Больше 40.", date: ConversationApi.formatter.date(from: "4/3/2022 20:20"), online: false, hasUnreadMessages: true, image: UIImage(named: "woman6.jpg")),
            Conversation(name: nil, message: "We need to assemble a team for the project by the 20th. We won't be able to do anything if we don't do it right now!", date: ConversationApi.formatter.date(from: "3/3/2022 23:55"), online: false, hasUnreadMessages: false, image: nil),
            Conversation(name: "Harry O'Brien", message: "hahahahaha", date: nil, online: false, hasUnreadMessages: true, image: nil),
            Conversation(name: "Charlie O'Kelly", message: "Very anxious about the latest news", date: ConversationApi.formatter.date(from: "2/3/2022 15:23"), online: false, hasUnreadMessages: false, image: UIImage(named: "man7.jpg")),
            Conversation(name: nil, message: "You can solve this problem through two pointers.", date: ConversationApi.formatter.date(from: "2/3/2022 11:30"), online: false, hasUnreadMessages: true, image: nil),
            Conversation(name: "Liza Frank", message: nil, date: ConversationApi.formatter.date(from: "1/3/2022 21:21"), online: false, hasUnreadMessages: false, image: UIImage(named: "woman7.jpg")),
            Conversation(name: "Olesya Romanova", message: "Сегодня начала", date: ConversationApi.formatter.date(from: "1/3/2022 17:40"), online: false, hasUnreadMessages: true, image: nil),
            Conversation(name: "Artem Belyaev", message: nil, date: ConversationApi.formatter.date(from: "1/1/2022 15:28"), online: false, hasUnreadMessages: false, image: UIImage(named: "man8.jpg")),
            Conversation(name: "Alla Timkanova", message: "Хочу сказать, что ты молодец.", date: ConversationApi.formatter.date(from: "6/12/2021 18:19"), online: false, hasUnreadMessages: true, image: UIImage(named: "woman8.jpg")),
            Conversation(name: "Andrey Romanyuk", message: "Whoa! Did you try to set a breakpoint?", date: ConversationApi.formatter.date(from: "2/11/2021 10:27"), online: false, hasUnreadMessages: false, image: nil),
            Conversation(name: "Oleg Oparinov", message: "ААААААА!!!", date: ConversationApi.formatter.date(from: "17/9/2021 16:32"), online: false, hasUnreadMessages: true, image: nil)
        ]
    }
    
    static let messages = [
        ChatMessage(text: "Hi!", isIncoming: true, date: ConversationApi.formatter.date(from: "2/11/2019 9:10")),
        ChatMessage(text: "How are you? Whats going on???", isIncoming: true, date: ConversationApi.formatter.date(from: "2/11/2019 9:40")),
        ChatMessage(text: "Hi! Fine. Let's me tell you about Shakespeare.", isIncoming: false, date: ConversationApi.formatter.date(from: "2/11/2019 13:27")),
        ChatMessage(text: "Какая погода в Грузии?", isIncoming: false, date: ConversationApi.formatter.date(from: "3/5/2019 10:11")),
        ChatMessage(text: "В уездном городе N было так много парикмахерских заведений и бюро похоронных процессий, что казалось, жители города рождаются лишь затем, чтобы побриться, остричься, освежить голову вежеталем и сразу же умереть.", isIncoming: true, date: ConversationApi.formatter.date(from: "21/3/2019 10:27")),
        ChatMessage(text: "Отличная!", isIncoming: true, date: ConversationApi.formatter.date(from: "3/5/2019 10:30")),
        ChatMessage(text: "Здесь Паша Эмильевич, обладавший сверхъестественным чутьем, понял, что сейчас его будут бить, может быть, даже ногами.", isIncoming: false, date: ConversationApi.formatter.date(from: "1/8/2017 10:30")),
        ChatMessage(text: "Дверь открылась. Остап прошел в комнату, которая могла быть обставлена только существом с воображением дятла.", isIncoming: false, date: ConversationApi.formatter.date(from: "1/6/2016 10:30")),
        ChatMessage(text: "Держите гроссмейстера!", isIncoming: true, date: ConversationApi.formatter.date(from: "1/6/2016 10:33")),
        ChatMessage(text: "Киса, я хочу вас спросить, как художник художника: вы рисовать умеете?", isIncoming: true, date: ConversationApi.formatter.date(from: "1/8/2015 10:30"))
    ]
    
    static func getDefaultDate() -> Date {
        return ConversationApi.formatter.date(from: "1/1/2000 00:00")!
    }
    
    private enum Const {
        static let day: Double = 60*60*24
    }
}
