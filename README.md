# Desmanguezados
jogo da disciplina projeto de jogos


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


As ferramentass devem ser filhas do *FerramentasMgmt*

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

### Se o plugin não estiver ativo:
Projeto -> Configurações do Projeto -> Plugins -> Habilitado tem que estar marcado como Ativo
