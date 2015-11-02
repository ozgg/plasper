Talk Plasper
============

Tool that analyzes letter usage weights and reproduces syllables. The more statistics it has, the better texts are.

Installation
------------

`gem install plasper`

Usage
-----

`plasper [options] action`

    -h, --help                Show help
    -t, --text-file path      Path to file with text to analyze
    -w, --weights-file path   Path to file with initial weights in YAML format
    -o, --output-file path    Path to output file for dumping weights

Available options are

 * `dump` (default) — dump weights on screen
 * `talk` output one passage of text based on weights
 * `chat` chat with your monsters from the Id.

If `-t` parameter is set, given file is analyzed and used for building weights.

If `-w` parameter is set, given file is parsed and used for building weights, too.

One can use both `-t` and `-w` parameters, weights will be added.

If `-o` parameter is set, resulting weights will be dumped as YAML into that file. 
This can be useful in chat mode or for analyzing weights in texts from `-t` files.

Example of chat
---------------

    $ plasper -o /tmp/stat/yml chat
    Use ^D to exit.
    Ego: Hello.
     Id: Heloh
    Ego: This is a version of English-speaking folks.
     Id: Englo
    Ego: Englo yourself.
     Id: A yolis
    Ego: Now I'll add several sentences. This will give more flexity.
     Id: Fll akiow h-si thexiseve thingll. A wi eversiolkspexity moll adddd olof.
    Ego: Several sentences are good. They add entropy. They increase weights!
     Id: Tyoon willf wing shese ise. She adddddd ng akis tyofoflo.
    Ego: If you give only word, it responds with word. If you give sentence, 
         plasper responds with sentence. If you give several sentences, it uses 
         passages.
     Id: Foroures wincentht ong fo sese iseives gise eng seng. Ores fllou wes 
         tese thise a it ghesive reles. Wisaloll iveyous ongi wo.
    Ego: Every input is analyzed.
     Id: Wi isal mo renordds

So, one can see that it learns.

На русском тоже есть пример.

    $ plasper -o /tmp/stat.yml chat
    Use ^D to exit.
    Ego: Привет.
     Id: Привет
    Ego: Как дела?
     Id: Прив
    Ego: Ты накурился что ли?
     Id: Лсял тыде ли накака
    Ego: Будут ли красные пятки торчать из грядки, если их достаточно хорошо закопать?
     Id: Гропят
    Ego: Это ты такое предложение высказываешь, значит?
     Id: Будки эткрет
    Ego: А если мы попробуем два предложения в абзаце? Так ведь прокатит, наверное? А?
     Id: Чатоженорили ваеториеслое. Дь мыемы. Приеночтыся.
    Ego: Ну уже хоть что-то получается. Нужно развивать и продвигать тему.
     Id: Прн нуракаедьд поригацелазв просли а нуедь. Еся чияд вем пожемы мутоедли 
         патацешорч едла прятьвыет чачаза кужешьва хое тосядь. Акри муже пятое ак но 
         ткабу лаено в а тьпр игрето нивакрорят.
    Ego: Осталось проработать момент с весами и правильным составлением слов, когда 
         нечего подставлять.
     Id: Ты торенигрое тьнучт влутьнак атать ну
    Ego: Но в целом круто вышло, пласпер.
     Id: Кабужное знерядесто прутстымы азышо тобоеть

