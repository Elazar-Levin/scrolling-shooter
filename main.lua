debug = true;
mute=false;
pause = false;

dir = 1;
canShoot = true;
rockets = false;
canShootTimerMax = 0.15;
canShootTimer = canShootTimerMax;
createEnemyTimerMax = 1.5;
createEnemyTimer = createEnemyTimerMax;
invincibleTimerMax = 5;
invincibleTimer = invincibleTimerMax;
lifepwupTimerMax = math.random(10, 20);
lifepwupTimer = lifepwupTimerMax; 
rocketpwupTimerMax=math.random(15, 25);
rocketpwupTimer=rocketpwupTimerMax
rocketTimerMax=8;
rocketTimer=rocketTimerMax

bulletImg = nil;
enemyImg = nil;
rocketImg = nil;
rocketpwup = nil;
repairpwup = nil;
diagpwup = nil;
doublepwup = nil;
lifepwup = nil;
coinpwup = nil;

music =nil;

bullets = {};
enemies = {};
powerups = {}
score = 0;
Alive = true;
enemySpeed = 50;
lives =3;
invincible = false;


player ={
	img = nil,
	hitImg = nil,
	x=50,
	y=600,
	speed = 150

}

function collides(x1,y1,w1,h1,x2,y2,w2,h2)
	return x1< x2 + w2 and 
		x2 < x1 + w1 and
		y1 < y2 + h2 and 
		y2 < y1 + h1
end

function getDist(x1,y1,x2,y2)
	return math.sqrt(math.pow(x2-x1,2)+math.pow(y2-y1,2));
end

function getNearestEnemy()
	nearest =0;
	dist = 10000;
	for i,enemy in ipairs(enemies) do
		if getDist(player.x,player.y,enemy.x,enemy.y)<=dist and enemy.y<player.y then
			dist= getDist(player.x,player.y,enemy.x,enemy.y);
			nearest = i;
		end
	end
	return nearest,dist;

end

function getAngle(i,dist)
	enemy = enemies[i];
	x= enemy.x-player.x;
	y= player.y-enemy.y;
end	

function love.load(arg)
	player.img = love.graphics.newImage('assets/plane.png');
	player.hitImg= love.graphics.newImage('assets/hit.png');
	bulletImg  = love.graphics.newImage('assets/bullet.png');
	enemyImg = love.graphics.newImage('assets/enemy.png');
	rocketImg = love.graphics.newImage('assets/rocket.png');
	rocketpwup = love.graphics.newImage('assets/missile.png');
	repairpwup = love.graphics.newImage('assets/repair.png');
	diagpwup = love.graphics.newImage('assets/diag.png');
	doublepwup = love.graphics.newImage('assets/double.png');
	lifepwup = love.graphics.newImage('assets/life.png');
	coinpwup = love.graphics.newImage('assets/coin.png');

	music = love.audio.newSource('assets/MetallicMistress.mp3',"stream");
	music:play();
end

function love.update(dt)
	if pause or mute then 
		music:pause()
	end
	if not music:isPlaying() and not mute and not pause then
		music:play();
	end
	if not pause then
		enemySpeed = enemySpeed + 1.5 *dt;


		canShootTimer = canShootTimer - (1 * dt);
		if canShootTimer < 0 then
			canShoot =true;
		end

		createEnemyTimer = createEnemyTimer - 1*dt;
		if createEnemyTimer < 0 then
			enemy = {x = math.random(10, love.graphics.getWidth() - 10 - enemyImg:getWidth()), y = -10, lives = 3, img = enemyImg};
			table.insert(enemies, enemy);
			createEnemyTimer = createEnemyTimerMax;

		end

		lifepwupTimer = lifepwupTimer - 1*dt;
		if lifepwupTimer<0 then

			lifepwupTimerMax = math.random(10, 20);
			lifepwupTimer = lifepwupTimerMax;
			powerup = { x = math.random(10, love.graphics.getWidth() - lifepwup:getWidth()),y = -10 ,speed = 150, img = lifepwup, type = "life"};
			table.insert(powerups,powerup);


		end

		rocketpwupTimer = rocketpwupTimer - 1*dt;
		if rocketpwupTimer<0 then

			rocketpwupTimerMax = math.random(15, 25);
			rocketpwupTimer = rocketpwupTimerMax;
			powerup = { x = math.random(10, love.graphics.getWidth() - rocketpwup:getWidth()),y = -10 ,speed = 150, img = rocketpwup, type = "rocket"};
			table.insert(powerups,powerup);


		end
		rocketTimer = rocketTimer -1*dt;
		if rocketTimer < 0 then
			rocketTimer = rocketTimerMax;
			rockets = false;
		end
		if invincibleTimer>0 then
			invincibleTimer = invincibleTimer - 1*dt;
		else
			invincible = false;
		end

		if love.keyboard.isDown("left",'a') and player.x > 0 then
			player.x = player.x - player.speed*dt;
		elseif love.keyboard.isDown("right",'d') and player.x < (love.graphics.getWidth() - player.img:getWidth()) then
			player.x = player.x + player.speed*dt;
		end
		if love.keyboard.isDown("space","rctrl","lctrl") and canShoot then
			if rockets then
				bullet = {x = player.x + player.img:getWidth()/2, y = player.y,img = rocketImg,dmg = 3};
			else 	
				bullet = {x = player.x + player.img:getWidth()/2, y = player.y,img = bulletImg,dmg = 1};
			end
			if Alive then
				table.insert(bullets, bullet);
			end
			canShoot = false;
		
			if rockets then
				canShootTimerMax =0.3;
			else
				canShootTimerMax = 0.15;
			end
			canShootTimer = canShootTimerMax;
		end

		for i,bullet in ipairs(bullets) do
			bullet.y = bullet.y - (250 * dt);

			if bullet.y < 0 then
				table.remove(bullets,i);
			end
		end

		for i,enemy in ipairs(enemies) do
			enemy.y = enemy.y + enemySpeed * dt;

			if enemy.y>850 then
				table.remove(enemies,i);
			end
		end

		for i,powerup in ipairs(powerups) do
			powerup.y = powerup.y + powerup.speed *dt;
			if powerup.y>850 then
				table.remove(powerup,i);
			end
		end
		--collision detection
		if Alive then
			for i,enemy in ipairs(enemies) do
				for j, bullet in ipairs(bullets) do
					if collides(enemy.x,enemy.y,enemy.img:getWidth(), enemy.img:getHeight(), bullet.x, bullet.y, bullet.img:getWidth(),bullet.img:getHeight()) then
						enemy.lives = enemy.lives - bullet.dmg;
						table.remove(bullets,j);
						if enemy.lives <= 0 then
							table.remove(enemies,i);		
							score = score + 5;
							
						end
					end
				end
				for j, powerup in ipairs(powerups) do
					if collides(powerup.x,powerup.y,powerup.img:getWidth(), powerup.img:getHeight(), player.x, player.y, player.img:getWidth(), player.img:getHeight()) then
						table.remove(powerups,j);

						if powerup.type == "life" then
							if lives < 5 then
								lives = lives + 1;
								
							end
						elseif powerup.type == "rocket" then
							rocketTimer = rocketTimerMax;
							rockets = true;

							--do rocket shit here
						end
					end
				end

				if not invincible then
					if collides(enemy.x,enemy.y,enemy.img:getWidth(),enemy.img:getHeight(),player.x,player.y,player.img:getWidth(),player.img:getHeight()) then
						if lives>0 then 
							invincibleTimer= invincibleTimerMax;
							invincible = true;
							lives = lives - 1;
						else
							Alive =false;
						end
						table.remove(enemies,i);

					end
				end
			end
		end
		if not Alive and love.keyboard.isDown('r') then
			bullets = {};
			enemies = {};
			music:stop();
			music:play();
			canShootTimer = canShootTimerMax;
			createEnemyTimer = createEnemyTimerMax;

			player.x = 50;
			player.y = 600;
			lives = 3;
			score = 0;
			Alive = true;
			enemySpeed=50;
		end
	end
end

function love.draw(dt)
	
	if Alive then
		if invincible then
			if (math.floor(invincibleTimer)%2<1) then
				love.graphics.draw(player.hitImg,player.x,player.y);
			else
				love.graphics.draw(player.img,player.x,player.y);
			end
		else 	
			love.graphics.draw(player.img,player.x,player.y);
		end
	else 
		love.graphics.print("Press 'R' to restart", love.graphics:getWidth()/2-50, love.graphics:getHeight()/2-10)
	end
	for i, bullet in ipairs(bullets) do
  		love.graphics.draw(bullet.img, bullet.x, bullet.y);
	end
	for i, powerup in ipairs(powerups) do
  		love.graphics.draw(powerup.img, powerup.x, powerup.y);
	end
	for i,enemy in ipairs(enemies) do
		love.graphics.draw(enemy.img,enemy.x,enemy.y);
	end

	--lives
	love.graphics.print("Score: " .. score, 10, 10);
	if lives>=1 then
		love.graphics.draw(player.img,love.graphics:getWidth()-player.img:getWidth()/2-10,10,0,0.5,0.5);-- life 1
		if lives>=2 then
			love.graphics.draw(player.img,love.graphics:getWidth()-player.img:getWidth()-10,10,0,0.5,0.5);-- life 2
			if lives>=3 then
				love.graphics.draw(player.img,love.graphics:getWidth()-(player.img:getWidth()/2)*3-10,10,0,0.5,0.5);-- life 3
				if lives>=4 then
					love.graphics.draw(player.img,love.graphics:getWidth()-player.img:getWidth()*2-10,10,0,0.5,0.5);-- life 4
					if lives == 5 then 
						love.graphics.draw(player.img,love.graphics:getWidth()-(player.img:getWidth()/2)*5-10,10,0,0.5,0.5);-- life 5
					end
				end
			end
		end
	end
end

function love.keypressed(key)
	if key == "escape" then
		love.event.push('quit');
	end
	if key == "p" then
		pause = not pause;
	end
	if key == "m" then
		mute = not mute;
	end
end




function love.focus(f)-- handle pausing here
  pause=not f;
  if not f then
    print("LOST FOCUS");
    music:pause();
  else
    print("GAINED FOCUS")
    music:play();
  end
end
