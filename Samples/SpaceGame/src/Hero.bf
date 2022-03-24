using SDL2;

namespace SpaceGame
{
	class Hero : Entity
	{
		public const int cShootDelay = 10; // How many frames to delay between shots
		public const float cMoveSpeed = 4.0f;

		public int mHealth = 1;
		public bool mIsMovingX;
		public int mShootDelay;

		public int mReviveDelay = 0;
		public int mInvincibleDelay = 0;

		public override void Draw()
		{
			if (mReviveDelay > 0)
				return;

			if ((mInvincibleDelay > 0) && ((mInvincibleDelay / 5 % 2 == 0)))
				return;

			float x = mX - 29;
			float y = mY - 41;
			Image image = Images.sHero;

			SDL.Rect srcRect = .(0, 0, image.mWidth, image.mHeight);
			SDL.Rect destRect = .((int32)x, (int32)y, image.mWidth, image.mHeight);

			if (mIsMovingX)
			{
				int32 inset = (.)(srcRect.w * 0.09f);
				destRect.x += inset;
				destRect.w -= inset * 2;
			}

			SDL.RenderCopy(gGameApp.mRenderer, image.mTexture, &srcRect, &destRect);
		}

		public override void Update()
		{
			if (mReviveDelay > 0)
			{
				if (--mReviveDelay == 0)
					gGameApp.mScore = 0;
				return;
			}

			if (mInvincibleDelay > 0)
				mInvincibleDelay--;

			base.Update();
			if (mShootDelay > 0)
				mShootDelay--;

			if (mHealth < 0)
			{
				gGameApp.ExplodeAt(mX, mY, 1.0f, 0.5f);
				gGameApp.PlaySound(Sounds.sExplode, 1.2f, 0.6f);
				gGameApp.mDifficulty = 0;

				mHealth = 1;
				mReviveDelay = 100;
				mInvincibleDelay = 100;
			}
		}
	}

	
}
