using System;
using SDL2;
using System.Collections;

namespace SpaceGame
{
	static
	{
		public static GameApp gGameApp;
	}

	class GameApp : SDLApp
	{
		public List<Entity> mEntities = new List<Entity>() ~ DeleteContainerAndItems!(_);
		public Hero mHero;
		public int mScore;
		public float mDifficulty;
		public Random mRand = new Random() ~ delete _;
#if !NOTTF
		Font mFont ~ delete _;
#endif
		float mBkgPos;
		int mEmptyUpdates;
		bool mHasMoved;
		bool mHasShot;
		bool mPaused;

		public this()
		{
			gGameApp = this;

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

		public override void Init()
		{
			base.Init();
			Images.Init();
			if (mHasAudio)
				Sounds.Init();

			mFont = new Font();
			//mFont.Load("zorque.ttf", 24);
			mFont.Load("images/Main.fnt", 0);
		}

		public void DrawString(float x, float y, String str, SDL.Color color, bool centerX = false)
		{
			DrawString(mFont, x, y, str, color, centerX);
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

		public override void KeyDown(SDL.KeyboardEvent evt)
		{
			base.KeyDown(evt);
			if (evt.keysym.sym == .P)
				mPaused = !mPaused;
		}

		void HandleInputs()
		{
			float deltaX = 0;
			float deltaY = 0;
			float moveSpeed = Hero.cMoveSpeed;
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
				mHero.mShootDelay = Hero.cShootDelay;
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
			if (mPaused)
				return;

			base.Update();

			HandleInputs();
			SpawnEnemies();

			// Make the game harder over time
			mDifficulty += 0.0001f;

			// Scroll the background
			mBkgPos += 0.6f;
			if (mBkgPos > 1024)
				mBkgPos -= 1024;

			for (var entity in mEntities)
			{
				entity.mUpdateCnt++;
				entity.Update();
				if (entity.mIsDeleting)
				{
					// '@entity' refers to the enumerator itself
	                @entity.Remove();
					delete entity;
				}
			}
		}
	}
}
