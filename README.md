╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ


# Комментарий к текущему ДЗ

В ТЗ было сказано создать лейн под названием run_tests (запуск тестов на уже скомпилированном приложении). Добавив данный лейн, я столкнулась с ошибкой: „Name of the lane 'run_tests' is already taken by the action named 'run_tests’“, что логично: ведь у fastlane есть action run_tests. Наличие lane и action с одинаковыми именами приводит к путанице: что на самом деле вызывается?

Так что, run_tests => run_chat_tests

# Real-time Tinkoff Chat
