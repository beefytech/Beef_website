namespace SpaceGame
{
	class HeroBullet : Entity
	{
		public override void Update()
		{
			mY -= 8.0f;
			if (mY < -16)
				mIsDeleting = true;

			for (let entity in gGameApp.mEntities)
			{
				if (let enemy = entity as Enemy)
				{
					if ((enemy.mBoundingBox.Contains((.)(mX - entity.mX), (.)(mY - entity.mY))) && (enemy.mHealth > 0))
					{
						mIsDeleting = true;
						enemy.mHealth--;
						
						gGameApp.ExplodeAt(mX, mY, 0.25f, 1.25f);
						gGameApp.PlaySound(Sounds.sExplode, 0.5f, 1.5f);

						break;
					}
				}
			}
		}

		public override void Draw()
		{
			gGameApp.Draw(Images.sHeroLaser, mX - 8, mY - 9);
		}
	}
}
