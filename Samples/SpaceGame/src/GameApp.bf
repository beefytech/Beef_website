using System;
using SDL2;
using System.Collections.Generic;

namespace SpaceGame
{
	class GameApp : SDLApp
	{
		public List<Entity> mEntities = new List<Entity>() ~ DeleteContainerAndItems!(_);
		public Hero mHero;
		public int mScore;
		public float mDifficulty;
		public Random mRand = new Random() ~ delete _;
		Font mFont ~ delete _;
		float mBkgPos;
		int mEmptyUpdates;
		bool mHasMoved;
		bool mHasShot;

		public this()
		{
			mHero = new Hero();
			AddEntity(mHero);

			mHero.mY = 650;
			mHero.mX = 512;
		}

		public ~this()
		{
			Images.Dispose();
			Sounds.Dispose();
		}

		public new void Init()
		{
			base.Init();
			Images.Init();
			Sounds.Init();
			mFont = new Font();
			mFont.Load("zorque.ttf", 24);
		}

		public void DrawString(float x, float y, String str, SDL.Color color, bool centerX = false)
		{
			var x;

			SDL.SetRenderDrawColor(gGameApp.mRenderer, 255, 255, 255, 255);
			let surface = SDLTTF.RenderUTF8_Blended(mFont.mFont, str, color);
			let texture = SDL.CreateTextureFromSurface(mRenderer, surface);
			SDL.Rect srcRect = .(0, 0, surface.w, surface.h);

			if (centerX)
				x -= surface.w / 2;

			SDL.Rect destRect = .((int32)x, (int32)y, surface.w, surface.h);
			SDL.RenderCopy(mRenderer, texture, &srcRect, &destRect);
			SDL.FreeSurface(surface);
			SDL.DestroyTexture(texture);
		}

		public override void Draw()
		{
			Draw(Images.sSpaceImage, 0, mBkgPos - 1024);
			Draw(Images.sSpaceImage, 0, mBkgPos);

			for (var entity in mEntities)
				entity.Draw();

			DrawString(8, 4, scope String()..AppendF("SCORE: {}", mScore), .(64, 255, 64, 255));

			if ((!mHasMoved) || (!mHasShot))
				DrawString(mWidth / 2, 200, "Use cursor keys to move and Space to fire", .(255, 255, 255, 255), true);
		}

		public void ExplodeAt(float x, float y, float sizeScale, float speedScale)
		{
			let explosion = new Explosion();
			explosion.mSizeScale = sizeScale;
			explosion.mSpeedScale = speedScale;
			explosion.mX = x;
			explosion.mY = y;
			mEntities.Add(explosion);
		}

		public void AddEntity(Entity entity)
		{
			mEntities.Add(entity);
		}

		void HandleInputs()
		{
			float deltaX = 0;
			float deltaY = 0;
			float moveSpeed = 4.0f;
			if (IsKeyDown(.Left))
				deltaX -= moveSpeed;
			if (IsKeyDown(.Right))
				deltaX += moveSpeed;

			if (IsKeyDown(.Up))
				deltaY -= moveSpeed;
			if (IsKeyDown(.Down))
				deltaY += moveSpeed;

			if ((deltaX != 0) || (deltaY != 0))
			{
				mHero.mX = Math.Clamp(mHero.mX + deltaX, 10, mWidth - 10);
				mHero.mY = Math.Clamp(mHero.mY + deltaY, 10, mHeight - 10);
				mHasMoved = true;
			}
			mHero.mIsMovingX = deltaX != 0;

			if ((IsKeyDown(.Space)) && (mHero.mShootDelay == 0))
			{
				mHasShot = true;
				mHero.mShootDelay = 10;
				let bullet = new HeroBullet();
				bullet.mX = mHero.mX;
				bullet.mY = mHero.mY - 50;
				AddEntity(bullet);
				PlaySound(Sounds.sLaser, 0.1f);
			}
		}

		void SpawnSkirmisher()
		{
			let spawner = new EnemySkirmisher.Spawner();
			spawner.mLeftSide = mRand.NextDouble() < 0.5;
			spawner.mY = ((float)mRand.NextDouble() * 0.5f + 0.25f) * mHeight;
			AddEntity(spawner);
		}

		void SpawnGoliath()
		{
			let enemy = new EnemyGolaith();
			enemy.mX = ((float)mRand.NextDouble() * 0.5f + 0.25f) * mWidth;
			enemy.mY = -300;
			AddEntity(enemy);
		}

		void SpawnEnemies()
		{
			bool hasEnemies = false;
			for (var entity in mEntities)
				if (entity is Enemy)
					hasEnemies = true;
			if (hasEnemies)
				mEmptyUpdates = 0;
			else
				mEmptyUpdates++;

			float spawnScale = 0.4f + (mEmptyUpdates * 0.025f);
			spawnScale += mDifficulty;

			if (mRand.NextDouble() < 0.002f * spawnScale)
				SpawnSkirmisher();

			if (mRand.NextDouble() < 0.0005f * spawnScale)
				SpawnGoliath();
		}

		public override void Update()
		{
			base.Update();

			HandleInputs();
			SpawnEnemies();

			mDifficulty += 0.0001f;

			mBkgPos += 0.6f;

			if (mBkgPos > 1024)
				mBkgPos -= 1024;

			for (var entity in mEntities)
			{
				entity.mUpdateCnt++;
				entity.Update();
				if (entity.mIsDeleting)
				{
	                @entity.Remove();
					delete entity;
				}
			}
		}
	}
}
