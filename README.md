# Desmanguezados
Jogo desenvolvido para disciplina **Projeto de Jogos e Entretenimento Digital - 2025.1**

Acesse o [site do projeto](https://paulobfalmeida.github.io/desmanguezados/)



# Licença - PT BR

Este projeto possui diferentes licenças para código e assets:

## Código (GDScript) - Unlicense

**Todo o código-fonte escrito em GDScript está licenciado sob a Unlicense.**
Isso significa que você é livre para copiar, modificar, distribuir ou usar o código como quiser, inclusive para fins comerciais, sem nenhuma restrição.

Para mais detalhes, acesse [The Unlicense](https://unlicense.org).

## Assets (Artes e Áudios) - Uso Proprietário

**Todos os assets visuais e sonoros (imagens, sprites, tiles, músicas, efeitos sonoros, etc.) presentes neste projeto são de uso proprietário.**

Não é permitido copiar, redistribuir ou reutilizar essas artes e áudios em outros projetos, comerciais ou não.



# License - EN

This project uses different licenses for code and assets:

## Code (GDScript) - Unlicense

**All GDScript source code is licensed under the Unlicense.**
This means you are free to copy, modify, distribute, or use the code for any purpose, including commercial projects, without any restrictions.

For more details, visit [The Unlicense](https://unlicense.org).

## Assets (Art and Audio) - Proprietary

**All visual and audio assets (images, sprites, music, sound effects, etc.) used in this project are proprietary.**

You are not allowed to copy, redistribute, or reuse any of these assets in other projects, whether for commercial or non-commercial purposes.




# Guia de Desenvolvimento

Quando for começar a mexer no projeto, ir no Github Cliente antes e dar um ```Fetch Origin``` para ver se tem atualizações.


Se tiver, fazer o ```Pull``` para baixar as atualizações


*No Godot -> recarregar do disco*

Isso vai fazer usar o que está no baixado salvo no pc, em vez da versão dos arquivos abertos na godot (Que serão as antigas)

## Criação de Níveis

Para criar um nível novo, duplique um já existente, e troque o nome do arquivo da cena do godot (level.tscn) e o nome do nodo pai da cena, 
assim como crie um novo script para o nível na pasta *Scripts/Leveis/* lembre de ter como base no script
```gdscript
extends Level

func _ready() -> void:
	super()
```
Para que ele haja como level e chame a função de iniciar da classe Level


E lembre de ajustar no inspetor, no nodo Level (pai da cena), as propriedades do level, assim como o tempo de duração da partida


As árvores (tanto nativas quanto invasoras) devem ser filhas do *ArvoresColecao*


Os lixos devem ser filhos do *LixosColecao*


As ferramentas devem ser filhas do *FerramentasMgmt*

### Agua ao redor
Colocar agua ao redor do mapa evita o jogador poder jogar a ferramenta para 
fora do mapa (já que ela re-spawna se cair na agua)


Para isso usar o tile transparente de agua e fazer 20 tiles de distancia 
de fora da area visível (dá para usar o rect do tilemap para criar 
um quadrado 20x20 nas 2 diagonais opostas da área visível, 
e usar de guia para preencher todos os cantos)

### Adicionar o nível na seleção de níveis

Ir no script `Scripts/Autoloads/SceneManager.gd`, e adicionar um novo Level_id, no enum, referencias (arrastar o level.tscn criado para o script, para gerar a String de referência de qual cena ele vai instanciar) e nomes (Texto que aparece para selecionar o level)
```gdscript
enum Level_id {LEVEL_X}

const LEVEIS_REF  : Dictionary[Level_id, String] = {
	Level_id.LEVEL_X: "res://Cenas/Leveis/level_X.tscn",
}

const LEVEIS_NOME : Dictionary[Level_id, String] = {
	Level_id.LEVEL_X: "Level X que eu criei agora",
}
```

Assim o novo level deve ter sido adicionado e pode ser acessado no menu de seleção do jogo

## Guia de Instalação
Baixar o zip do projeto -> Godot 4 Importar projeto


## Plugins utilizados

[TileMapDual](https://github.com/pablogila/TileMapDual)

Não é um plugin, mas o shader da tela veio daqui [Screen Space Shaders](https://github.com/godotengine/godot-demo-projects/tree/4.2-31d1c0c/2d/screen_space_shaders).

### Se o plugin não estiver ativo:
Projeto -> Configurações do Projeto -> Plugins -> Habilitado tem que estar marcado como Ativo

## Outros Softwares

### Online
[Clumsy](https://jagt.github.io/clumsy/index.html) Para testar delay e perda de pacotes da internet, no próprio pc (localhost).
