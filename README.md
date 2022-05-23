╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ[![CI](https://github.com/TFS-iOS/chat-app-eoshtanko/actions/workflows/github.yml/badge.svg)](https://github.com/TFS-iOS/chat-app-eoshtanko/actions/workflows/github.yml)

# Комментарий к текущему ДЗ

В ТЗ было сказано создать лейн под названием run_tests (запуск тестов на уже скомпилированном приложении). Добавив данный лейн, я столкнулась с ошибкой: „Name of the lane 'run_tests' is already taken by the action named 'run_tests’“, что логично: ведь у fastlane есть action run_tests. Наличие lane и action с одинаковыми именами приводит к путанице: что на самом деле вызывается?

Так что, run_tests => run_chat_tests

Почти...

<p float="left">
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202022-05-23%20%D0%B2%2011.06.14.png" width="405" />
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/%D0%A1%D0%BD%D0%B8%D0%BC%D0%BE%D0%BA%20%D1%8D%D0%BA%D1%80%D0%B0%D0%BD%D0%B0%202022-05-23%20%D0%B2%2011.06.40.png" width="405" /> 
</p>

# Real-time Tinkoff Chat
<p float="left">
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/image1.PNG" width="270" />
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.51.09.png" width="270" /> 
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.46.35.png" width="270" />
</p>

<p float="left">
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.35.14.png" width="270" />
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.42.03.png" width="270" /> 
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.41.53.png" width="270" />
</p>

<p float="left">
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.40.41.png" width="270" />
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.35.38.png" width="270" /> 
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.40.55.png" width="270" />
</p>


<p float="left">
  <img src="https://github.com/TFS-iOS/chat-app-eoshtanko/blob/7d9b44ca8acd310551629ab7bb0f63a17fd0dacd/Illustrations/Simulator%20Screen%20Shot%20-%20iPhone%2011%20-%202022-05-21%20at%2013.31.56.png" width="270" />
</p>
