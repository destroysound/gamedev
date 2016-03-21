var game = new Phaser.Game(800, 800, Phaser.AUTO, '', { preload: preload, create: create, update: update });

function preload() {

    game.load.tilemap('castletiles', 'assets/tilemaps/castle.json', null, Phaser.Tilemap.TILED_JSON);
    game.load.image('castle', 'assets/tilemaps/tilesets/Castle.png');
    game.load.spritesheet('dude', 'assets/dude.png', 32, 48);

}

var map;
var terrain;
var buildings;
var decorations;

var player;

var cursors;

function create() {
  
    game.stage.backgroundColor = '#787878';

    //  The 'mario' key here is the Loader key given in game.load.tilemap
    map = game.add.tilemap('castletiles');

    //  The first parameter is the tileset name, as specified in the Tiled map editor (and in the tilemap json file)
    //  The second parameter maps this name to the Phaser.Cache key 'tiles'
    map.addTilesetImage('Castle', 'castle');
    
    //  Creates a layer from the World1 layer in the map data.
    //  A Layer is effectively like a Phaser.Sprite, so is added to the display list.
    terrain = map.createLayer('Terrain');
    buildings = map.createLayer('Buildings');
    decorations = map.createLayer('Decoration');
    map.setCollisionBetween(1, 10000, true, buildings);
    map.setCollisionBetween(1, 10000, true, decorations);
    terrain.debug = true;
    buildings.debug = true;

    //  This resizes the game world to match the layer dimensions
    terrain.resizeWorld();

    player = game.add.sprite(48, 48, 'dude');

    var respawn = game.add.group();

    map.createFromObjects('Objects', 101, '', 0, true, false, respawn);

    respawn.forEach(function (p) {
        player.reset(p.x, p.y);
    });

    game.camera.follow(player);

    game.physics.arcade.enable(player);

    cursors = game.input.keyboard.createCursorKeys();
}

function update() {

    game.physics.arcade.collide(player, buildings);
    game.physics.arcade.collide(player, decorations);

    player.body.velocity.set(0); 

    if (cursors.up.isDown) {
        player.body.velocity.y = -150;
    }
    else if (cursors.down.isDown) {
        player.body.velocity.y = 150;
    }
    if (cursors.left.isDown) {
        player.body.velocity.x = -150;
    }
    else if (cursors.right.isDown) {
        player.body.velocity.x = 150;
    }

}
