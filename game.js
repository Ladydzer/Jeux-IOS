// ============================================================================
// GALAXY DEFENDER - HTML5 Space Shooter
// ============================================================================

(function () {
  "use strict";

  // --- Canvas Setup ---
  const canvas = document.getElementById("gameCanvas");
  const ctx = canvas.getContext("2d");

  function resizeCanvas() {
    canvas.width = window.innerWidth;
    canvas.height = window.innerHeight;
  }
  resizeCanvas();
  window.addEventListener("resize", resizeCanvas);

  // --- Constants ---
  const PLAYER_SPEED = 6;
  const BULLET_SPEED = 10;
  const ENEMY_BULLET_SPEED = 4;
  const STAR_COUNT = 120;
  const PARTICLE_LIFE = 40;

  // --- Audio Engine (Web Audio API) ---
  const AudioCtx = window.AudioContext || window.webkitAudioContext;
  let audioCtx = null;

  function ensureAudio() {
    if (!audioCtx) audioCtx = new AudioCtx();
    if (audioCtx.state === "suspended") audioCtx.resume();
  }

  function playSound(type) {
    ensureAudio();
    if (!audioCtx) return;
    const t = audioCtx.currentTime;
    const osc = audioCtx.createOscillator();
    const gain = audioCtx.createGain();
    osc.connect(gain);
    gain.connect(audioCtx.destination);

    switch (type) {
      case "shoot":
        osc.type = "square";
        osc.frequency.setValueAtTime(600, t);
        osc.frequency.exponentialRampToValueAtTime(200, t + 0.1);
        gain.gain.setValueAtTime(0.15, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.1);
        osc.start(t);
        osc.stop(t + 0.1);
        break;
      case "explosion":
        osc.type = "sawtooth";
        osc.frequency.setValueAtTime(200, t);
        osc.frequency.exponentialRampToValueAtTime(30, t + 0.3);
        gain.gain.setValueAtTime(0.2, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.3);
        osc.start(t);
        osc.stop(t + 0.3);
        break;
      case "powerup":
        osc.type = "sine";
        osc.frequency.setValueAtTime(400, t);
        osc.frequency.exponentialRampToValueAtTime(1200, t + 0.2);
        gain.gain.setValueAtTime(0.15, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.25);
        osc.start(t);
        osc.stop(t + 0.25);
        break;
      case "hit":
        osc.type = "triangle";
        osc.frequency.setValueAtTime(150, t);
        osc.frequency.exponentialRampToValueAtTime(50, t + 0.15);
        gain.gain.setValueAtTime(0.2, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.15);
        osc.start(t);
        osc.stop(t + 0.15);
        break;
      case "laser":
        osc.type = "sawtooth";
        osc.frequency.setValueAtTime(900, t);
        osc.frequency.exponentialRampToValueAtTime(300, t + 0.15);
        gain.gain.setValueAtTime(0.1, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.15);
        osc.start(t);
        osc.stop(t + 0.15);
        break;
      case "wave":
        osc.type = "sine";
        osc.frequency.setValueAtTime(300, t);
        osc.frequency.linearRampToValueAtTime(600, t + 0.15);
        osc.frequency.linearRampToValueAtTime(300, t + 0.3);
        osc.frequency.linearRampToValueAtTime(800, t + 0.5);
        gain.gain.setValueAtTime(0.12, t);
        gain.gain.exponentialRampToValueAtTime(0.001, t + 0.5);
        osc.start(t);
        osc.stop(t + 0.5);
        break;
      case "gameover":
        osc.type = "sawtooth";
        osc.frequency.setValueAtTime(400, t);
        osc.frequency.linearRampToValueAtTime(100, t + 0.8);
        gain.gain.setValueAtTime(0.2, t);
        gain.gain.linearRampToValueAtTime(0, t + 1);
        osc.start(t);
        osc.stop(t + 1);
        break;
    }
  }

  // --- Game State ---
  let state = "menu"; // menu, playing, paused, gameover
  let score = 0;
  let highScore = parseInt(localStorage.getItem("galaxyDefenderHigh") || "0");
  let lives = 3;
  let wave = 1;
  let waveTimer = 0;
  let waveMessage = "";
  let waveMessageTimer = 0;
  let shakeTimer = 0;
  let shakeIntensity = 0;
  let comboCount = 0;
  let comboTimer = 0;
  let frameCount = 0;

  // --- Entity Arrays ---
  let player = null;
  let bullets = [];
  let enemyBullets = [];
  let enemies = [];
  let particles = [];
  let powerups = [];
  let stars = [];
  let floatingTexts = [];

  // --- Input ---
  const keys = {};
  let touchX = null;
  let touchY = null;
  let touching = false;
  let touchShootInterval = null;

  // --- Star Field ---
  function initStars() {
    stars = [];
    for (let i = 0; i < STAR_COUNT; i++) {
      stars.push({
        x: Math.random() * canvas.width,
        y: Math.random() * canvas.height,
        speed: 0.3 + Math.random() * 2,
        size: 0.5 + Math.random() * 2,
        brightness: 0.3 + Math.random() * 0.7,
      });
    }
  }
  initStars();

  function updateStars() {
    for (const s of stars) {
      s.y += s.speed;
      if (s.y > canvas.height) {
        s.y = 0;
        s.x = Math.random() * canvas.width;
      }
    }
  }

  function drawStars() {
    for (const s of stars) {
      ctx.fillStyle = `rgba(255,255,255,${s.brightness})`;
      ctx.fillRect(s.x, s.y, s.size, s.size);
    }
  }

  // --- Player ---
  function createPlayer() {
    return {
      x: canvas.width / 2,
      y: canvas.height - 80,
      w: 40,
      h: 40,
      speed: PLAYER_SPEED,
      shootCooldown: 0,
      shootRate: 12,
      power: 1, // 1=single, 2=double, 3=triple
      shieldTimer: 0,
      invincible: 0,
      thrustAnim: 0,
    };
  }

  function drawPlayer(p) {
    if (p.invincible > 0 && Math.floor(p.invincible / 3) % 2 === 0) return;

    ctx.save();
    ctx.translate(p.x, p.y);

    // Thrust flame
    p.thrustAnim += 0.2;
    const flameLen = 12 + Math.sin(p.thrustAnim * 5) * 5;
    const flameGrad = ctx.createLinearGradient(0, p.h / 2, 0, p.h / 2 + flameLen);
    flameGrad.addColorStop(0, "#fff");
    flameGrad.addColorStop(0.3, "#ffa500");
    flameGrad.addColorStop(1, "rgba(255,50,0,0)");
    ctx.fillStyle = flameGrad;
    ctx.beginPath();
    ctx.moveTo(-8, p.h / 2);
    ctx.lineTo(8, p.h / 2);
    ctx.lineTo(0, p.h / 2 + flameLen);
    ctx.closePath();
    ctx.fill();

    // Ship body
    const bodyGrad = ctx.createLinearGradient(0, -p.h / 2, 0, p.h / 2);
    bodyGrad.addColorStop(0, "#6cf");
    bodyGrad.addColorStop(1, "#2266aa");
    ctx.fillStyle = bodyGrad;
    ctx.beginPath();
    ctx.moveTo(0, -p.h / 2);
    ctx.lineTo(-p.w / 2, p.h / 2);
    ctx.lineTo(-p.w / 4, p.h / 3);
    ctx.lineTo(p.w / 4, p.h / 3);
    ctx.lineTo(p.w / 2, p.h / 2);
    ctx.closePath();
    ctx.fill();

    // Cockpit
    ctx.fillStyle = "#aef";
    ctx.beginPath();
    ctx.ellipse(0, -2, 6, 10, 0, 0, Math.PI * 2);
    ctx.fill();

    // Wings detail
    ctx.strokeStyle = "#8df";
    ctx.lineWidth = 1.5;
    ctx.beginPath();
    ctx.moveTo(-p.w / 2 + 3, p.h / 2 - 4);
    ctx.lineTo(-5, 0);
    ctx.moveTo(p.w / 2 - 3, p.h / 2 - 4);
    ctx.lineTo(5, 0);
    ctx.stroke();

    // Shield
    if (p.shieldTimer > 0) {
      const alpha = p.shieldTimer < 60 ? (p.shieldTimer / 60) * 0.4 : 0.4;
      ctx.strokeStyle = `rgba(100,200,255,${alpha})`;
      ctx.lineWidth = 2;
      ctx.beginPath();
      ctx.arc(0, 0, 30, 0, Math.PI * 2);
      ctx.stroke();
      ctx.fillStyle = `rgba(100,200,255,${alpha * 0.3})`;
      ctx.fill();
    }

    ctx.restore();
  }

  function updatePlayer(p) {
    // Keyboard
    if (keys["ArrowLeft"] || keys["KeyA"]) p.x -= p.speed;
    if (keys["ArrowRight"] || keys["KeyD"]) p.x += p.speed;
    if (keys["ArrowUp"] || keys["KeyW"]) p.y -= p.speed;
    if (keys["ArrowDown"] || keys["KeyS"]) p.y += p.speed;

    // Touch
    if (touching && touchX !== null) {
      const dx = touchX - p.x;
      const dy = touchY - p.y;
      const dist = Math.sqrt(dx * dx + dy * dy);
      if (dist > 5) {
        p.x += (dx / dist) * Math.min(p.speed, dist);
        p.y += (dy / dist) * Math.min(p.speed, dist);
      }
    }

    // Bounds
    p.x = Math.max(p.w / 2, Math.min(canvas.width - p.w / 2, p.x));
    p.y = Math.max(p.h / 2, Math.min(canvas.height - p.h / 2, p.y));

    // Shooting
    if (p.shootCooldown > 0) p.shootCooldown--;
    const wantShoot = keys["Space"] || keys["KeyZ"] || touching;
    if (wantShoot && p.shootCooldown <= 0) {
      playerShoot(p);
      p.shootCooldown = p.shootRate;
    }

    if (p.shieldTimer > 0) p.shieldTimer--;
    if (p.invincible > 0) p.invincible--;
  }

  function playerShoot(p) {
    playSound("shoot");
    if (p.power >= 1) {
      bullets.push({ x: p.x, y: p.y - p.h / 2, vx: 0, vy: -BULLET_SPEED, w: 4, h: 12, damage: 1 });
    }
    if (p.power >= 2) {
      bullets.push({ x: p.x - 12, y: p.y - p.h / 2 + 5, vx: 0, vy: -BULLET_SPEED, w: 4, h: 12, damage: 1 });
      bullets.push({ x: p.x + 12, y: p.y - p.h / 2 + 5, vx: 0, vy: -BULLET_SPEED, w: 4, h: 12, damage: 1 });
    }
    if (p.power >= 3) {
      bullets.push({ x: p.x - 8, y: p.y - p.h / 2, vx: -1.5, vy: -BULLET_SPEED, w: 4, h: 12, damage: 1 });
      bullets.push({ x: p.x + 8, y: p.y - p.h / 2, vx: 1.5, vy: -BULLET_SPEED, w: 4, h: 12, damage: 1 });
    }
  }

  function drawBullet(b) {
    const grad = ctx.createLinearGradient(b.x, b.y - b.h / 2, b.x, b.y + b.h / 2);
    grad.addColorStop(0, "#fff");
    grad.addColorStop(0.5, "#6ef");
    grad.addColorStop(1, "rgba(100,200,255,0)");
    ctx.fillStyle = grad;
    ctx.fillRect(b.x - b.w / 2, b.y - b.h / 2, b.w, b.h);
  }

  // --- Enemies ---
  const ENEMY_TYPES = {
    basic: {
      w: 30, h: 30, hp: 1, score: 100, color1: "#f44", color2: "#a00",
      speed: 1.5, shootRate: 0, pattern: "straight",
    },
    zigzag: {
      w: 32, h: 28, hp: 2, score: 200, color1: "#fa0", color2: "#a60",
      speed: 1.2, shootRate: 120, pattern: "zigzag",
    },
    tank: {
      w: 40, h: 40, hp: 5, score: 400, color1: "#a4f", color2: "#608",
      speed: 0.8, shootRate: 80, pattern: "straight",
    },
    fast: {
      w: 24, h: 24, hp: 1, score: 150, color1: "#ff0", color2: "#aa0",
      speed: 3, shootRate: 0, pattern: "sine",
    },
    boss: {
      w: 70, h: 50, hp: 30, score: 2000, color1: "#f0f", color2: "#a0a",
      speed: 0.5, shootRate: 30, pattern: "boss",
    },
  };

  function spawnEnemy(type, x, y) {
    const t = ENEMY_TYPES[type];
    enemies.push({
      type, x, y, w: t.w, h: t.h,
      hp: t.hp + Math.floor(wave / 3),
      maxHp: t.hp + Math.floor(wave / 3),
      score: t.score,
      speed: t.speed + wave * 0.05,
      shootRate: t.shootRate,
      shootCooldown: Math.random() * (t.shootRate || 60),
      pattern: t.pattern,
      color1: t.color1, color2: t.color2,
      time: Math.random() * 100,
      startX: x,
    });
  }

  function drawEnemy(e) {
    ctx.save();
    ctx.translate(e.x, e.y);

    // Body
    const grad = ctx.createRadialGradient(0, 0, 2, 0, 0, e.w / 2);
    grad.addColorStop(0, e.color1);
    grad.addColorStop(1, e.color2);
    ctx.fillStyle = grad;

    if (e.type === "boss") {
      // Boss shape
      ctx.beginPath();
      ctx.moveTo(0, -e.h / 2);
      ctx.lineTo(e.w / 2, -e.h / 4);
      ctx.lineTo(e.w / 2, e.h / 4);
      ctx.lineTo(e.w / 4, e.h / 2);
      ctx.lineTo(-e.w / 4, e.h / 2);
      ctx.lineTo(-e.w / 2, e.h / 4);
      ctx.lineTo(-e.w / 2, -e.h / 4);
      ctx.closePath();
      ctx.fill();
      ctx.strokeStyle = "#fff";
      ctx.lineWidth = 1;
      ctx.stroke();

      // Boss eye
      ctx.fillStyle = "#ff0";
      ctx.beginPath();
      ctx.arc(0, -5, 8, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = "#f00";
      ctx.beginPath();
      ctx.arc(0, -5, 4, 0, Math.PI * 2);
      ctx.fill();

      // HP bar
      const barW = e.w;
      const hpRatio = e.hp / e.maxHp;
      ctx.fillStyle = "#300";
      ctx.fillRect(-barW / 2, -e.h / 2 - 10, barW, 5);
      ctx.fillStyle = hpRatio > 0.5 ? "#0f0" : hpRatio > 0.25 ? "#ff0" : "#f00";
      ctx.fillRect(-barW / 2, -e.h / 2 - 10, barW * hpRatio, 5);
    } else if (e.type === "tank") {
      ctx.beginPath();
      ctx.arc(0, 0, e.w / 2, 0, Math.PI * 2);
      ctx.fill();
      ctx.fillStyle = e.color1;
      ctx.beginPath();
      ctx.arc(0, 0, e.w / 4, 0, Math.PI * 2);
      ctx.fill();
      // HP bar
      if (e.maxHp > 1) {
        const barW = e.w;
        const hpRatio = e.hp / e.maxHp;
        ctx.fillStyle = "#300";
        ctx.fillRect(-barW / 2, -e.h / 2 - 8, barW, 4);
        ctx.fillStyle = hpRatio > 0.5 ? "#0f0" : "#ff0";
        ctx.fillRect(-barW / 2, -e.h / 2 - 8, barW * hpRatio, 4);
      }
    } else {
      // Standard invader shape
      ctx.beginPath();
      ctx.moveTo(0, -e.h / 2);
      ctx.lineTo(e.w / 2, 0);
      ctx.lineTo(e.w / 3, e.h / 2);
      ctx.lineTo(-e.w / 3, e.h / 2);
      ctx.lineTo(-e.w / 2, 0);
      ctx.closePath();
      ctx.fill();

      // Eyes
      ctx.fillStyle = "#fff";
      ctx.fillRect(-6, -4, 4, 4);
      ctx.fillRect(2, -4, 4, 4);
    }

    ctx.restore();
  }

  function updateEnemy(e) {
    e.time += 0.03;

    switch (e.pattern) {
      case "straight":
        e.y += e.speed;
        break;
      case "zigzag":
        e.y += e.speed;
        e.x = e.startX + Math.sin(e.time * 3) * 60;
        break;
      case "sine":
        e.y += e.speed;
        e.x = e.startX + Math.sin(e.time * 4) * 40;
        break;
      case "boss":
        if (e.y < 80) {
          e.y += e.speed;
        } else {
          e.x = canvas.width / 2 + Math.sin(e.time) * (canvas.width / 3);
        }
        break;
    }

    // Shooting
    if (e.shootRate > 0) {
      e.shootCooldown--;
      if (e.shootCooldown <= 0) {
        e.shootCooldown = e.shootRate;
        enemyShoot(e);
      }
    }
  }

  function enemyShoot(e) {
    if (e.type === "boss") {
      // Boss fires spread
      for (let a = -0.3; a <= 0.3; a += 0.3) {
        enemyBullets.push({
          x: e.x, y: e.y + e.h / 2,
          vx: Math.sin(a) * 2, vy: ENEMY_BULLET_SPEED,
          w: 6, h: 6,
        });
      }
    } else {
      const dx = player ? player.x - e.x : 0;
      const dy = player ? player.y - e.y : 1;
      const dist = Math.sqrt(dx * dx + dy * dy) || 1;
      enemyBullets.push({
        x: e.x, y: e.y + e.h / 2,
        vx: (dx / dist) * ENEMY_BULLET_SPEED * 0.5,
        vy: ENEMY_BULLET_SPEED,
        w: 5, h: 5,
      });
    }
    playSound("laser");
  }

  function drawEnemyBullet(b) {
    ctx.fillStyle = "#f44";
    ctx.shadowColor = "#f00";
    ctx.shadowBlur = 8;
    ctx.beginPath();
    ctx.arc(b.x, b.y, b.w / 2, 0, Math.PI * 2);
    ctx.fill();
    ctx.shadowBlur = 0;
  }

  // --- Power-ups ---
  const POWERUP_TYPES = ["weapon", "shield", "life", "bomb"];
  const POWERUP_COLORS = { weapon: "#0f0", shield: "#0af", life: "#f0f", bomb: "#fa0" };
  const POWERUP_LABELS = { weapon: "W", shield: "S", life: "+", bomb: "B" };

  function spawnPowerup(x, y) {
    const type = POWERUP_TYPES[Math.floor(Math.random() * POWERUP_TYPES.length)];
    powerups.push({ x, y, type, w: 20, h: 20, time: 0 });
  }

  function drawPowerup(p) {
    p.time += 0.05;
    ctx.save();
    ctx.translate(p.x, p.y);
    ctx.rotate(p.time);

    ctx.strokeStyle = POWERUP_COLORS[p.type];
    ctx.lineWidth = 2;
    ctx.fillStyle = `${POWERUP_COLORS[p.type]}44`;

    // Diamond shape
    ctx.beginPath();
    ctx.moveTo(0, -p.h / 2);
    ctx.lineTo(p.w / 2, 0);
    ctx.lineTo(0, p.h / 2);
    ctx.lineTo(-p.w / 2, 0);
    ctx.closePath();
    ctx.fill();
    ctx.stroke();

    ctx.restore();

    // Label
    ctx.fillStyle = "#fff";
    ctx.font = "bold 12px monospace";
    ctx.textAlign = "center";
    ctx.fillText(POWERUP_LABELS[p.type], p.x, p.y + 4);
  }

  function applyPowerup(type) {
    playSound("powerup");
    switch (type) {
      case "weapon":
        player.power = Math.min(3, player.power + 1);
        addFloatingText(player.x, player.y - 30, "POWER UP!", "#0f0");
        break;
      case "shield":
        player.shieldTimer = 300;
        addFloatingText(player.x, player.y - 30, "SHIELD!", "#0af");
        break;
      case "life":
        lives = Math.min(5, lives + 1);
        addFloatingText(player.x, player.y - 30, "+1 VIE", "#f0f");
        break;
      case "bomb":
        // Destroy all enemies on screen
        for (const e of enemies) {
          spawnExplosion(e.x, e.y, e.color1, 10);
          score += e.score;
        }
        enemies = [];
        shakeTimer = 15;
        shakeIntensity = 8;
        addFloatingText(canvas.width / 2, canvas.height / 2, "BOMBE!", "#fa0");
        playSound("explosion");
        break;
    }
  }

  // --- Particles ---
  function spawnExplosion(x, y, color, count = 15) {
    for (let i = 0; i < count; i++) {
      const angle = Math.random() * Math.PI * 2;
      const speed = 1 + Math.random() * 4;
      particles.push({
        x, y,
        vx: Math.cos(angle) * speed,
        vy: Math.sin(angle) * speed,
        life: PARTICLE_LIFE,
        maxLife: PARTICLE_LIFE,
        size: 2 + Math.random() * 4,
        color,
      });
    }
  }

  function updateParticles() {
    for (let i = particles.length - 1; i >= 0; i--) {
      const p = particles[i];
      p.x += p.vx;
      p.y += p.vy;
      p.vx *= 0.97;
      p.vy *= 0.97;
      p.life--;
      if (p.life <= 0) particles.splice(i, 1);
    }
  }

  function drawParticles() {
    for (const p of particles) {
      const alpha = p.life / p.maxLife;
      ctx.globalAlpha = alpha;
      ctx.fillStyle = p.color;
      ctx.beginPath();
      ctx.arc(p.x, p.y, p.size * alpha, 0, Math.PI * 2);
      ctx.fill();
    }
    ctx.globalAlpha = 1;
  }

  // --- Floating Texts ---
  function addFloatingText(x, y, text, color) {
    floatingTexts.push({ x, y, text, color, life: 60 });
  }

  function updateFloatingTexts() {
    for (let i = floatingTexts.length - 1; i >= 0; i--) {
      floatingTexts[i].y -= 1;
      floatingTexts[i].life--;
      if (floatingTexts[i].life <= 0) floatingTexts.splice(i, 1);
    }
  }

  function drawFloatingTexts() {
    for (const ft of floatingTexts) {
      const alpha = ft.life / 60;
      ctx.globalAlpha = alpha;
      ctx.fillStyle = ft.color;
      ctx.font = "bold 16px monospace";
      ctx.textAlign = "center";
      ctx.fillText(ft.text, ft.x, ft.y);
    }
    ctx.globalAlpha = 1;
  }

  // --- Wave System ---
  function startWave() {
    waveMessage = `VAGUE ${wave}`;
    waveMessageTimer = 120;
    playSound("wave");
    waveTimer = 0;

    const isBossWave = wave % 5 === 0;

    if (isBossWave) {
      waveMessage = `BOSS - VAGUE ${wave}`;
      setTimeout(() => spawnEnemy("boss", canvas.width / 2, -60), 1000);
    } else {
      const numEnemies = 5 + wave * 2;
      const types = ["basic"];
      if (wave >= 2) types.push("zigzag");
      if (wave >= 3) types.push("fast");
      if (wave >= 4) types.push("tank");

      for (let i = 0; i < numEnemies; i++) {
        const type = types[Math.floor(Math.random() * types.length)];
        const delay = i * 300 + Math.random() * 500;
        const x = 50 + Math.random() * (canvas.width - 100);
        setTimeout(() => {
          if (state === "playing") spawnEnemy(type, x, -40);
        }, delay);
      }
    }
  }

  function checkWaveComplete() {
    waveTimer++;
    if (enemies.length === 0 && waveTimer > 180) {
      wave++;
      startWave();
    }
  }

  // --- Collision Detection ---
  function rectCollide(a, b) {
    return (
      a.x - a.w / 2 < b.x + b.w / 2 &&
      a.x + a.w / 2 > b.x - b.w / 2 &&
      a.y - a.h / 2 < b.y + b.h / 2 &&
      a.y + a.h / 2 > b.y - b.h / 2
    );
  }

  function handleCollisions() {
    // Player bullets vs enemies
    for (let bi = bullets.length - 1; bi >= 0; bi--) {
      const b = bullets[bi];
      for (let ei = enemies.length - 1; ei >= 0; ei--) {
        const e = enemies[ei];
        if (rectCollide(b, e)) {
          bullets.splice(bi, 1);
          e.hp -= b.damage;
          spawnExplosion(b.x, b.y, "#6ef", 5);

          if (e.hp <= 0) {
            // Enemy destroyed
            spawnExplosion(e.x, e.y, e.color1, e.type === "boss" ? 40 : 15);
            playSound("explosion");

            comboCount++;
            comboTimer = 90;
            const comboMult = Math.min(comboCount, 10);
            const pts = e.score * comboMult;
            score += pts;

            if (comboCount > 1) {
              addFloatingText(e.x, e.y, `${pts} x${comboMult}`, "#ff0");
            } else {
              addFloatingText(e.x, e.y, `${pts}`, "#fff");
            }

            // Drop power-up (15% chance, guaranteed from boss)
            if (e.type === "boss" || Math.random() < 0.15) {
              spawnPowerup(e.x, e.y);
            }

            enemies.splice(ei, 1);
            shakeTimer = 5;
            shakeIntensity = 3;
          } else {
            playSound("hit");
          }
          break;
        }
      }
    }

    // Enemy bullets vs player
    if (player && player.invincible <= 0) {
      for (let i = enemyBullets.length - 1; i >= 0; i--) {
        if (rectCollide(enemyBullets[i], player)) {
          enemyBullets.splice(i, 1);
          if (player.shieldTimer > 0) {
            player.shieldTimer = Math.max(0, player.shieldTimer - 60);
            spawnExplosion(player.x, player.y, "#0af", 8);
            playSound("hit");
          } else {
            playerHit();
          }
        }
      }
    }

    // Enemies vs player
    if (player && player.invincible <= 0) {
      for (let i = enemies.length - 1; i >= 0; i--) {
        if (rectCollide(enemies[i], player)) {
          if (player.shieldTimer > 0) {
            enemies[i].hp -= 3;
            if (enemies[i].hp <= 0) {
              spawnExplosion(enemies[i].x, enemies[i].y, enemies[i].color1, 15);
              score += enemies[i].score;
              enemies.splice(i, 1);
            }
            player.shieldTimer = Math.max(0, player.shieldTimer - 100);
          } else {
            spawnExplosion(enemies[i].x, enemies[i].y, enemies[i].color1, 15);
            enemies.splice(i, 1);
            playerHit();
          }
        }
      }
    }

    // Power-ups vs player
    if (player) {
      for (let i = powerups.length - 1; i >= 0; i--) {
        if (rectCollide(powerups[i], player)) {
          applyPowerup(powerups[i].type);
          powerups.splice(i, 1);
        }
      }
    }
  }

  function playerHit() {
    lives--;
    playSound("hit");
    spawnExplosion(player.x, player.y, "#6cf", 20);
    shakeTimer = 10;
    shakeIntensity = 6;

    if (lives <= 0) {
      gameOver();
    } else {
      player.invincible = 90;
      player.power = Math.max(1, player.power - 1);
    }
  }

  function gameOver() {
    state = "gameover";
    playSound("gameover");
    if (score > highScore) {
      highScore = score;
      localStorage.setItem("galaxyDefenderHigh", highScore.toString());
    }
  }

  // --- Update & Draw ---
  function update() {
    if (state !== "playing") return;

    frameCount++;
    updatePlayer(player);

    // Update bullets
    for (let i = bullets.length - 1; i >= 0; i--) {
      bullets[i].x += bullets[i].vx;
      bullets[i].y += bullets[i].vy;
      if (bullets[i].y < -20) bullets.splice(i, 1);
    }

    // Update enemy bullets
    for (let i = enemyBullets.length - 1; i >= 0; i--) {
      enemyBullets[i].x += enemyBullets[i].vx;
      enemyBullets[i].y += enemyBullets[i].vy;
      if (enemyBullets[i].y > canvas.height + 20) enemyBullets.splice(i, 1);
    }

    // Update enemies
    for (let i = enemies.length - 1; i >= 0; i--) {
      updateEnemy(enemies[i]);
      if (enemies[i].y > canvas.height + 60) {
        enemies.splice(i, 1);
      }
    }

    // Update power-ups
    for (let i = powerups.length - 1; i >= 0; i--) {
      powerups[i].y += 1;
      if (powerups[i].y > canvas.height + 20) powerups.splice(i, 1);
    }

    handleCollisions();
    updateParticles();
    updateFloatingTexts();
    updateStars();
    checkWaveComplete();

    // Combo timer
    if (comboTimer > 0) {
      comboTimer--;
      if (comboTimer <= 0) comboCount = 0;
    }

    // Wave message
    if (waveMessageTimer > 0) waveMessageTimer--;
    if (shakeTimer > 0) shakeTimer--;
  }

  function draw() {
    ctx.clearRect(0, 0, canvas.width, canvas.height);

    // Background
    const bgGrad = ctx.createLinearGradient(0, 0, 0, canvas.height);
    bgGrad.addColorStop(0, "#000010");
    bgGrad.addColorStop(1, "#000030");
    ctx.fillStyle = bgGrad;
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    // Screen shake
    if (shakeTimer > 0) {
      const sx = (Math.random() - 0.5) * shakeIntensity;
      const sy = (Math.random() - 0.5) * shakeIntensity;
      ctx.save();
      ctx.translate(sx, sy);
    }

    drawStars();

    if (state === "menu") {
      drawMenu();
    } else if (state === "playing" || state === "paused") {
      // Draw game entities
      for (const b of bullets) drawBullet(b);
      for (const b of enemyBullets) drawEnemyBullet(b);
      for (const e of enemies) drawEnemy(e);
      for (const p of powerups) drawPowerup(p);
      drawParticles();
      drawFloatingTexts();
      if (player) drawPlayer(player);
      drawHUD();

      // Wave message
      if (waveMessageTimer > 0) {
        const alpha = waveMessageTimer > 80 ? 1 : waveMessageTimer / 80;
        ctx.globalAlpha = alpha;
        ctx.fillStyle = "#fff";
        ctx.font = `bold ${36 + (120 - waveMessageTimer) * 0.2}px monospace`;
        ctx.textAlign = "center";
        ctx.fillText(waveMessage, canvas.width / 2, canvas.height / 2);
        ctx.globalAlpha = 1;
      }

      if (state === "paused") drawPauseOverlay();
    } else if (state === "gameover") {
      // Still draw entities in background
      for (const b of bullets) drawBullet(b);
      for (const e of enemies) drawEnemy(e);
      drawParticles();
      drawGameOver();
    }

    if (shakeTimer > 0) ctx.restore();
  }

  // --- UI Screens ---
  function drawMenu() {
    // Title
    ctx.fillStyle = "#fff";
    ctx.font = "bold 48px monospace";
    ctx.textAlign = "center";
    ctx.fillText("GALAXY", canvas.width / 2, canvas.height * 0.25);

    const titleGrad = ctx.createLinearGradient(
      canvas.width / 2 - 150, 0, canvas.width / 2 + 150, 0
    );
    titleGrad.addColorStop(0, "#6cf");
    titleGrad.addColorStop(0.5, "#fff");
    titleGrad.addColorStop(1, "#6cf");
    ctx.fillStyle = titleGrad;
    ctx.font = "bold 52px monospace";
    ctx.fillText("DEFENDER", canvas.width / 2, canvas.height * 0.25 + 55);

    // Subtitle
    ctx.fillStyle = "#888";
    ctx.font = "16px monospace";
    ctx.fillText("SPACE SHOOTER", canvas.width / 2, canvas.height * 0.25 + 85);

    // High score
    if (highScore > 0) {
      ctx.fillStyle = "#fa0";
      ctx.font = "18px monospace";
      ctx.fillText(`MEILLEUR SCORE: ${highScore}`, canvas.width / 2, canvas.height * 0.5);
    }

    // Instructions
    ctx.fillStyle = "#6cf";
    ctx.font = "bold 22px monospace";
    const isMobile = "ontouchstart" in window;
    if (isMobile) {
      ctx.fillText("TOUCHEZ POUR JOUER", canvas.width / 2, canvas.height * 0.65);
      ctx.fillStyle = "#888";
      ctx.font = "14px monospace";
      ctx.fillText("Glissez pour bouger, tir automatique", canvas.width / 2, canvas.height * 0.65 + 30);
    } else {
      ctx.fillText("APPUYEZ SUR ESPACE", canvas.width / 2, canvas.height * 0.65);
      ctx.fillStyle = "#888";
      ctx.font = "14px monospace";
      ctx.fillText("Flèches/WASD: Bouger | Espace: Tirer | P: Pause", canvas.width / 2, canvas.height * 0.65 + 30);
    }

    // Decorative ship
    const shipY = canvas.height * 0.42;
    ctx.save();
    ctx.translate(canvas.width / 2, shipY);
    ctx.scale(2, 2);
    const grad = ctx.createLinearGradient(0, -20, 0, 20);
    grad.addColorStop(0, "#6cf");
    grad.addColorStop(1, "#2266aa");
    ctx.fillStyle = grad;
    ctx.beginPath();
    ctx.moveTo(0, -20);
    ctx.lineTo(-20, 20);
    ctx.lineTo(-10, 13);
    ctx.lineTo(10, 13);
    ctx.lineTo(20, 20);
    ctx.closePath();
    ctx.fill();
    ctx.fillStyle = "#aef";
    ctx.beginPath();
    ctx.ellipse(0, -2, 6, 10, 0, 0, Math.PI * 2);
    ctx.fill();
    ctx.restore();
  }

  function drawHUD() {
    // Score
    ctx.fillStyle = "#fff";
    ctx.font = "bold 20px monospace";
    ctx.textAlign = "left";
    ctx.fillText(`SCORE: ${score}`, 15, 30);

    // Wave
    ctx.fillStyle = "#aaa";
    ctx.font = "14px monospace";
    ctx.fillText(`VAGUE ${wave}`, 15, 50);

    // Combo
    if (comboCount > 1) {
      ctx.fillStyle = "#ff0";
      ctx.font = "bold 16px monospace";
      ctx.fillText(`COMBO x${Math.min(comboCount, 10)}`, 15, 70);
    }

    // Lives
    ctx.textAlign = "right";
    for (let i = 0; i < lives; i++) {
      const lx = canvas.width - 20 - i * 28;
      ctx.fillStyle = "#6cf";
      ctx.beginPath();
      ctx.moveTo(lx, 15);
      ctx.lineTo(lx - 8, 30);
      ctx.lineTo(lx, 26);
      ctx.lineTo(lx + 8, 30);
      ctx.closePath();
      ctx.fill();
    }

    // Power level
    ctx.fillStyle = "#0f0";
    ctx.font = "12px monospace";
    ctx.textAlign = "right";
    const powerLabel = ["", "I", "II", "III"][player.power];
    ctx.fillText(`TIR: ${powerLabel}`, canvas.width - 15, 50);

    // Shield indicator
    if (player.shieldTimer > 0) {
      ctx.fillStyle = "#0af";
      ctx.fillText(`BOUCLIER: ${Math.ceil(player.shieldTimer / 60)}s`, canvas.width - 15, 66);
    }
  }

  function drawPauseOverlay() {
    ctx.fillStyle = "rgba(0,0,0,0.6)";
    ctx.fillRect(0, 0, canvas.width, canvas.height);
    ctx.fillStyle = "#fff";
    ctx.font = "bold 40px monospace";
    ctx.textAlign = "center";
    ctx.fillText("PAUSE", canvas.width / 2, canvas.height / 2 - 20);
    ctx.font = "18px monospace";
    ctx.fillStyle = "#aaa";
    ctx.fillText("Appuyez sur P pour reprendre", canvas.width / 2, canvas.height / 2 + 20);
  }

  function drawGameOver() {
    ctx.fillStyle = "rgba(0,0,0,0.7)";
    ctx.fillRect(0, 0, canvas.width, canvas.height);

    ctx.fillStyle = "#f44";
    ctx.font = "bold 44px monospace";
    ctx.textAlign = "center";
    ctx.fillText("GAME OVER", canvas.width / 2, canvas.height * 0.3);

    ctx.fillStyle = "#fff";
    ctx.font = "24px monospace";
    ctx.fillText(`SCORE: ${score}`, canvas.width / 2, canvas.height * 0.45);

    ctx.fillStyle = "#fa0";
    ctx.font = "20px monospace";
    ctx.fillText(`VAGUE ATTEINTE: ${wave}`, canvas.width / 2, canvas.height * 0.52);

    if (score >= highScore && score > 0) {
      ctx.fillStyle = "#ff0";
      ctx.font = "bold 22px monospace";
      ctx.fillText("NOUVEAU RECORD!", canvas.width / 2, canvas.height * 0.6);
    } else {
      ctx.fillStyle = "#888";
      ctx.font = "16px monospace";
      ctx.fillText(`MEILLEUR: ${highScore}`, canvas.width / 2, canvas.height * 0.6);
    }

    ctx.fillStyle = "#6cf";
    ctx.font = "bold 20px monospace";
    const isMobile = "ontouchstart" in window;
    ctx.fillText(
      isMobile ? "TOUCHEZ POUR REJOUER" : "ESPACE POUR REJOUER",
      canvas.width / 2,
      canvas.height * 0.75
    );
  }

  // --- Game Flow ---
  function startGame() {
    ensureAudio();
    state = "playing";
    score = 0;
    lives = 3;
    wave = 1;
    comboCount = 0;
    comboTimer = 0;
    bullets = [];
    enemyBullets = [];
    enemies = [];
    particles = [];
    powerups = [];
    floatingTexts = [];
    player = createPlayer();
    startWave();
  }

  // --- Input Handlers ---
  document.addEventListener("keydown", (e) => {
    keys[e.code] = true;
    if (e.code === "Space") {
      e.preventDefault();
      if (state === "menu" || state === "gameover") startGame();
    }
    if (e.code === "KeyP" && state === "playing") {
      state = "paused";
    } else if (e.code === "KeyP" && state === "paused") {
      state = "playing";
    }
  });

  document.addEventListener("keyup", (e) => {
    keys[e.code] = false;
  });

  // Touch
  canvas.addEventListener("touchstart", (e) => {
    e.preventDefault();
    ensureAudio();
    if (state === "menu" || state === "gameover") {
      startGame();
      return;
    }
    touching = true;
    const touch = e.touches[0];
    const rect = canvas.getBoundingClientRect();
    touchX = touch.clientX - rect.left;
    touchY = touch.clientY - rect.top;
  }, { passive: false });

  canvas.addEventListener("touchmove", (e) => {
    e.preventDefault();
    const touch = e.touches[0];
    const rect = canvas.getBoundingClientRect();
    touchX = touch.clientX - rect.left;
    touchY = touch.clientY - rect.top;
  }, { passive: false });

  canvas.addEventListener("touchend", (e) => {
    e.preventDefault();
    touching = false;
    touchX = null;
    touchY = null;
  }, { passive: false });

  // Mouse fallback for touch
  canvas.addEventListener("mousedown", (e) => {
    ensureAudio();
    if (state === "menu" || state === "gameover") {
      startGame();
      return;
    }
    touching = true;
    touchX = e.clientX;
    touchY = e.clientY;
  });

  canvas.addEventListener("mousemove", (e) => {
    if (touching) {
      touchX = e.clientX;
      touchY = e.clientY;
    }
  });

  canvas.addEventListener("mouseup", () => {
    touching = false;
    touchX = null;
    touchY = null;
  });

  // --- Main Loop ---
  function gameLoop() {
    updateStars();
    update();
    draw();
    requestAnimationFrame(gameLoop);
  }

  gameLoop();
})();
