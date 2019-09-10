using SDL2;

namespace SpaceGame
{
	class Explosion : Entity
	{
		public float mSizeScale;
		public float mSpeedScale;

		int32 Frame
		{
			get
			{
				return (int32)(mSpeedScale * mUpdateCnt);
			}
		}

		public override void Update()
		{
			if (Frame == 42)
				mIsDeleting = true;
		}

		public override void Draw()
		{
			//using (g.PushScale(mSizeScale, mSizeScale))
			//gGameApp.Draw(Images.sExplosion[Frame / 6, Frame % 6], -64, -64);

			let image = Images.sExplosionImage;
			float x = mX - (65 * mSizeScale);
			float y = mY - (65 * mSizeScale);

			SDL.Rect srcRect = .((Frame % 6) * 130, (Frame / 6) * 130, 130, 130);
			SDL.Rect destRect = .((int32)x, (int32)y, (int32)(mSizeScale * 130), (int32)(mSizeScale * 130));
			SDL.RenderCopy(gGameApp.mRenderer, image.mTexture, &srcRect, &destRect);
		}
	}
}
