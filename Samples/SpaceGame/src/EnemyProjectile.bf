using SDL2;

namespace SpaceGame
{
	class EnemyProjectile : Entity
	{
		public override void Update()
		{
			if (gGameApp.mHero.mInvincibleDelay > 0)
				return;

			SDL.Rect heroBoundingBox = .(-30, -30, 60, 60);
			if (heroBoundingBox.Contains((.)(mX - gGameApp.mHero.mX), (.)(mY - gGameApp.mHero.mY)))
			{
				gGameApp.ExplodeAt(mX, mY, 0.25f, 1.25f);
				gApp.PlaySound(Sounds.sExplode, 0.5f, 1.5f);
				gGameApp.mHero.mHealth--;
			}
		}
	}
}
