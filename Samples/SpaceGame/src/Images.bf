using System;
using SDL2;
using System.Collections;

namespace SpaceGame
{
	static class Images
	{
		public static Image sSpaceImage;
		public static Image sExplosionImage;
		public static Image sHero;
		public static Image sHeroLaser;
		public static Image sEnemySkirmisher;
		public static Image sEnemyBomber;
		public static Image sEnemyGoliath;
		public static Image sEnemyLaser;
		public static Image sEnemyBomb;
		public static Image sEnemyPhaser;

		static List<Image> sImages = new .() ~ delete _;

		public static Result<Image> Load(StringView fileName)
		{
			Image image = new Image();
			if (image.Load(fileName) case .Err)
			{
				delete image;
				return .Err;
			}
			sImages.Add(image);
			return image;
		}

		public static void Dispose()
		{
			ClearAndDeleteItems(sImages);
		}

		public static Result<void> Init()
		{
			sHero = Try!(Load("images/Ship01.png"));
			sHeroLaser = Try!(Load("images/Bullet03.png"));
			sEnemySkirmisher = Try!(Load("images/Ship02.png"));
			sEnemyBomber = Try!(Load("images/Ship03.png"));
			sEnemyGoliath = Try!(Load("images/Ship04.png"));
			sEnemyLaser = Try!(Load("images/Bullet02.png"));
			sEnemyBomb = Try!(Load("images/Bullet01.png"));
			sEnemyPhaser = Try!(Load("images/Bullet04.png"));

			sSpaceImage = Try!(Load("images/space.jpg"));
			sExplosionImage = Try!(Load("images/explosion.png"));

			return .Ok;
		}
	}
}
