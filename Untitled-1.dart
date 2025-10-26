<!doctype html> 
<html lang="pt-BR">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>Pika Surfando nas Ondas</title>
<style>
  html, body {
    height: 100%;
    margin: 0;
    display: flex;  
    justify-content: center;
    align-items: center;
    background: #cceeff; /* Fundo azul claro */
  }
  canvas {
    background: #cceeff; /* Azul claro dentro do canvas também */
    border: 1px solid #0077cc;
  }
</style>
</head>
<body>
<canvas id="game" width="900" height="300"></canvas>
<script>
const canvas = document.getElementById('game');
const ctx = canvas.getContext('2d');
const groundY = 260;

let dino = {x:50, y:groundY-60, w:50, h:60, vy:0, jumping:false, crouching:false};
let obstacles = [];
let gravity = 0.6;
let speed = 6;          
let frame = 0;
let score = 0;
let gameOver = false;

// === Função para carregar imagens ===
function loadImage(name) {
  const base = window.location.href.substring(0, window.location.href.lastIndexOf('/') + 1);
  const img = new Image();
  img.src = base + name;
  img.onload = () => console.log(name + ' carregou!');
  img.onerror = () => console.error('Erro ao carregar: ' + img.src);
  return img;
}

// === Imagens ===
const dinoSprite = loadImage("pika.png");
const seaImage = loadImage("mar.png");
const sunImage = loadImage("sol.png"); // 🌞 Adicionamos o Sol
const obstacleSprites = [
  loadImage("obistaculo1.png"),
  loadImage("obistaculo2.png"),
  loadImage("obistaculo3.png")
];

// === Criar obstáculos ===
function addObstacle() {
  const index = Math.floor(Math.random() * obstacleSprites.length);
  const sprite = obstacleSprites[index];
  const h = dino.h * 1.3;
  const w = dino.w * 1.3;
  obstacles.push({ 
    x: canvas.width, 
    y: groundY - h + 15, 
    w: w, 
    h: h, 
    sprite: sprite 
  });
}

// === Pulo suave ===
function jump() {
  if (!dino.jumping) { 
    dino.vy = -12;
    dino.jumping = true; 
  }
}

// === Controles ===
document.addEventListener('keydown', e=>{
  if(e.code==='Space') jump();
  if(e.code==='ArrowDown') dino.crouching = true;
  if(e.code==='KeyR' && gameOver) restart();
});

document.addEventListener('keyup', e=>{
  if(e.code==='ArrowDown') dino.crouching = false;
});

// === Reiniciar ===
function restart() {
  obstacles = [];
  frame = 0;
  score = 0;
  speed = 6;      
  gameOver = false;
  dino.y = groundY - dino.h;
  dino.vy = 0;
  dino.jumping = false;
  addObstacle();
}

// === Função de colisão ===
function checkCollision(a, b) {
  const paddingDino = 12;
  const paddingObs = 8;
  const dinoLeft = a.x + paddingDino;
  const dinoRight = a.x + a.w - paddingDino;
  const dinoTop = a.y + paddingDino;
  const dinoBottom = a.y + a.h - paddingDino;
  const obsLeft = b.x + paddingObs;
  const obsRight = b.x + b.w - paddingObs;
  const obsTop = b.y + paddingObs;
  const obsBottom = b.y + b.h - paddingObs;
  return (
    dinoRight > obsLeft &&
    dinoLeft < obsRight &&
    dinoBottom > obsTop &&
    dinoTop < obsBottom
  );
}

// === Atualizar lógica ===
function update() {
  if(!gameOver){
    frame++;
    score += 0.5;

    dino.vy += gravity;
    dino.y += dino.vy;

    if(dino.crouching && !dino.jumping){
      dino.h = 30;
    } else {
      dino.h = 60;
    }

    if(dino.y + dino.h >= groundY) {
      dino.y = groundY - dino.h;
      dino.vy = 0;
      dino.jumping = false;
    }

    if(frame % 45 === 0) addObstacle();

    for(let i=obstacles.length-1;i>=0;i--){
      let o = obstacles[i];
      o.x -= speed;
      if(o.x + o.w < 0) obstacles.splice(i,1);
      if(o.sprite.complete && o.sprite.naturalWidth > 0 && checkCollision(dino, o)) {
        gameOver = true;
      }
    }

    if(frame % 600 === 0) speed += 0.4;
  }
}

// === Desenhar ===
function draw() {
  ctx.clearRect(0,0,canvas.width,canvas.height);

  // Fundo azul claro
  ctx.fillStyle = "#cceeff";
  ctx.fillRect(0,0,canvas.width,canvas.height);

  // Desenhar Sol no canto superior direito 🌞
  if (sunImage.complete && sunImage.naturalWidth > 0) {
    ctx.drawImage(sunImage, canvas.width - 80, 20, 60, 60);
  }

  // Piso do mar
  if(seaImage.complete && seaImage.naturalWidth > 0){
    ctx.drawImage(seaImage, 0, groundY, canvas.width, canvas.height - groundY);
  } else {
    ctx.fillStyle='#0099ff';
    ctx.fillRect(0,groundY,canvas.width,canvas.height-groundY);
  }

  // Pika surfando
  let offsetY = Math.sin(frame * 0.12) * 1;
  let offsetX = Math.cos(frame * 0.08) * 0.7;
  let tilt = Math.sin(frame * 0.1) * 0.05;

  ctx.save();
  ctx.translate(dino.x + dino.w/2 + offsetX, dino.y + dino.h/2 + offsetY);
  ctx.rotate(tilt);
  if(dinoSprite.complete && dinoSprite.naturalWidth > 0){
    ctx.drawImage(dinoSprite, -dino.w/2, -dino.h/2, dino.w, dino.h);
  } else {
    ctx.fillStyle = '#4CAF50';
    ctx.fillRect(-dino.w/2, -dino.h/2, dino.w, dino.h);
  }
  ctx.restore();

  // Obstáculos
  obstacles.forEach(o=>{
    if(o.sprite.complete && o.sprite.naturalWidth > 0){
      ctx.drawImage(o.sprite, o.x, o.y, o.w, o.h);
    }
  });

  // Pontuação
  ctx.fillStyle='black';
  ctx.font='18px Arial';
  ctx.fillText('Pontuação: '+Math.floor(score), 10, 25);

  // Tela de Game Over
  if(gameOver){
    ctx.fillStyle='black';
    ctx.font='40px Arial';
    ctx.fillText('GAME OVER', canvas.width/2 - 120, canvas.height/2);
    ctx.font='20px Arial';
    ctx.fillText('Pressione R para reiniciar', canvas.width/2 - 110, canvas.height/2 + 30);
  }
}

// === Inicializar ===
addObstacle();
function loop(){ 
  update(); 
  draw(); 
  requestAnimationFrame(loop); 
}

loop();
</script>
</body>
</html>
