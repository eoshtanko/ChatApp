╰( ͡° ͜ʖ ͡° )つ──☆*:・ﾟ

1. Сделала дополнительно удаление каналов :)

2. CoreData предоставляет готовые инструменты для логирования. 
 Достояно лишь добавить Launch Argument
-com.apple.CoreData.SQLDebug 4 (в Product -> Scheme -> Edit Scheme)
Можно даже выбрать log level:
1. SQL statements and their execution time
2. Values that are bound in the statement
3. Fetched managed object IDs
4. SQLite EXPLAIN statement

Однако, думаю, в задании от нас ожидали, что мы пропишем логирование сами, что и сделала. 
Включить/отключить логирование Вы можете с помощью ключа isCoreDataLoggingEnable в Info.plist.
- - - - - - - - - - - - - - - - - - - - - - - -
Я сражалась отважно, но два warning-а, связанных со сменой стиля status bar победить пока не удалось :( 
Надеюсь, это некритично. 
