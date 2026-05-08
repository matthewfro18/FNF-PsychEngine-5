package objects;

class FlareonCharacter extends Character
{
	static inline final MOUTH_OFFSET_X:Float = 130;
	static inline final MOUTH_OFFSET_Y:Float = 300;
	static inline final BOUNCE_DURATION:Float = 0.12;
	static inline final BOUNCE_HEIGHT:Float = 12;
	static inline final MISS_FLASH_DURATION:Float = 0.15;

	var tail:FlxSprite;
	var body:FlxSprite;
	var head:FlxSprite;
	var mouth:FlxSprite;

	var time:Float = 0;
	var singTimer:Float = 0;
	var bounceTimer:Float = 0;
	var missFlashTimer:Float = 0;
	var currentAnim:String = 'idle';
	var mouthIsOpen:Bool = false;

	public function new(x:Float, y:Float, ?character:String = 'flareon', ?isPlayer:Bool = false)
	{
		super(x, y, character, isPlayer);

		curCharacter = character;
		healthIcon = 'flareon-pixel';
		healthColorArray = [247, 123, 62];
		positionArray = [0, 300];
		cameraPosition = [0, 0];
		singDuration = 4;
		noAntialiasing = true;
		antialiasing = false;
		hasMissAnimations = true;

		animation.destroyAnimations();
		offset.set();
		origin.set(width * 0.5, height * 0.5);

		tail = makePart('tail');
		body = makePart('torso');
		head = makePart('head');
		mouth = makePart('mouth');
		mouth.antialiasing = false;

		for (anim in ['idle', 'hey', 'singLEFT', 'singDOWN', 'singUP', 'singRIGHT', 'singLEFTmiss', 'singDOWNmiss', 'singUPmiss', 'singRIGHTmiss'])
			addOffset(anim);

		playAnim('idle', true);
	}

	function makePart(image:String):FlxSprite
	{
		var spr = new FlxSprite();
		spr.loadGraphic(Paths.image(image));
		spr.antialiasing = false;
		spr.flipX = flipX;
		return spr;
	}

	override function update(elapsed:Float)
	{
		if (debugMode)
		{
			super.update(elapsed);
			return;
		}

		if (missFlashTimer > 0)
		{
			missFlashTimer -= elapsed;
			setPartsColor(0xFF00A0FF);
		}
		else
			setPartsColor(FlxColor.WHITE);

		if (currentAnim == 'idle')
			applyIdle(elapsed);
		else
		{
			applySingPose(currentAnim);
			singTimer -= elapsed;
			if (singTimer <= 0)
			{
				currentAnim = 'idle';
				bounceTimer = BOUNCE_DURATION;
				mouthIsOpen = false;
				mouth.alpha = 0;
				mouth.visible = false;
			}
		}

		if (bounceTimer > 0)
		{
			bounceTimer -= elapsed;
			var bounceProgress = bounceTimer / BOUNCE_DURATION;
			head.y -= Math.sin(bounceProgress * Math.PI) * BOUNCE_HEIGHT;
		}

		updateMouth();
		holdTimer = currentAnim.startsWith('sing') ? holdTimer + elapsed : 0;

		tail.update(elapsed);
		body.update(elapsed);
		head.update(elapsed);
		mouth.update(elapsed);
	}

	function applyIdle(elapsed:Float)
	{
		time += elapsed;

		var bodyBob = Math.sin(time * 2) * 3;
		var bodyBreath = 1 + Math.sin(time * 1.2) * 0.02;
		positionPart(body, 0, bodyBob, 0, bodyBreath, bodyBreath);

		var headBob = bodyBob * 0.3 + Math.sin(time * 2.2);
		var headWiggle = Math.sin(time * 4) * 2;
		positionPart(head, 5, headBob, headWiggle);

		var mouthBob = headBob * 0.5 + Math.sin(time * 3) * 0.5;
		positionPart(mouth, 0, mouthBob);
		var mouthWiggle = Math.sin(time * 6) * 1.5;
		mouth.angle = head.angle + mouthWiggle;

		var tailWag = Math.sin(time * 3 + 0.5) * 12;
		positionPart(tail, -40, bodyBob * 0.6, tailWag);
		setMouth(false);
	}

	function applySingPose(anim:String)
	{
		positionPart(body, 0, 0, 0, 1, 1);
		mouthIsOpen = true;

		switch(anim.replace('miss', ''))
		{
			case 'singLEFT':
				positionPart(head, -5, 0, -0.5);
				positionPart(tail, -45, 5, -5);
				mouth.alpha = 1;
				mouth.visible = true;
			case 'singDOWN':
				positionPart(head, 5, 0);
				positionPart(tail, -40, 20);
				mouth.alpha = 1;
				mouth.visible = true;
			case 'singUP':
				positionPart(head, 5, 0, 0.5);
				positionPart(tail, -35, 0, 10);
				mouth.alpha = 1;
				mouth.visible = true;
			case 'singRIGHT':
				positionPart(head, 15, 0, 0.5);
				positionPart(tail, -35, 5, 5);
				mouth.alpha = 1;
				mouth.visible = true;
			case 'idle':
				mouth.alpha = 0;
				mouth.visible = false;
			case 'hey':
				positionPart(head, 0, -10, 0);
				positionPart(tail, -40, 10, 0);
				mouth.alpha = 1;
				mouth.visible = true;
		}

		setMouth(true);
	}

	function positionPart(spr:FlxSprite, offsetX:Float, offsetY:Float, angleValue:Float = 0, scaleX:Float = 1, scaleY:Float = 1)
	{
		spr.x = x + offsetX;
		spr.y = y + offsetY;
		spr.angle = angleValue;
		spr.scale.set(scaleX, scaleY);
		spr.flipX = flipX;
	}

	function updateMouth()
	{
		var mouthOffset = flipX ? -MOUTH_OFFSET_X : MOUTH_OFFSET_X;
		mouth.x = head.x + mouthOffset;
		mouth.y = head.y + MOUTH_OFFSET_Y;
		mouth.angle = head.angle;
		mouth.flipX = flipX;
		mouth.scale.set(head.scale.x, head.scale.y);
		mouth.antialiasing = head.antialiasing;
		mouth.alpha = head.alpha;
		mouth.visible = head.visible && mouthIsOpen;
		mouth.updateHitbox();
	}

	function setMouth(open:Bool)
	{
		mouth.setGraphicSize(12, open ? 10 : 6);
		mouth.updateHitbox();
	}

	function setPartsColor(colorValue:FlxColor)
	{
		for (spr in [tail, body, head])
			spr.color = colorValue;
	}

	function copyPartValues(spr:FlxSprite, partVisible:Bool = true)
	{
		spr.cameras = cameras;
		spr.scrollFactor.copyFrom(scrollFactor);
		spr.alpha = alpha;
		spr.visible = visible && partVisible;
	}

	override public function draw()
	{
		for (spr in [tail, body, head])
		{
			copyPartValues(spr);
			spr.draw();
		}
		copyPartValues(mouth, mouthIsOpen);
		mouth.draw();
	}

	override public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		specialAnim = false;
		currentAnim = AnimName;
		_lastPlayedAnimation = AnimName;
		if (AnimName.startsWith('sing'))
		{
			singTimer = 0.18;
			if (AnimName.endsWith('miss'))
				missFlashTimer = MISS_FLASH_DURATION;
		}
		else if (AnimName.startsWith('idle') || AnimName == 'danceLeft' || AnimName == 'danceRight')
		{
			currentAnim = 'idle';
			mouthIsOpen = false;
		}
	}

	override public function dance()
	{
		if (!debugMode && !skipDance && !specialAnim)
			playAnim('idle');
	}

	override public function hasAnimation(anim:String):Bool
		return animOffsets.exists(anim);

	override public function isAnimationFinished():Bool
		return singTimer <= 0;
}
