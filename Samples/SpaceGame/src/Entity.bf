namespace SpaceGame
{
	class Entity
	{
		public bool mIsDeleting;
		public int32 mUpdateCnt;
		public float mX;
		public float mY;
		
		public bool IsOffscreen(float marginX, float marginY)
		{
			return ((mX < -marginX) || (mX >= gGameApp.mWidth + marginX) ||
				(mY < -marginY) || (mY >= gGameApp.mHeight + marginY));
		}

		public virtual void Update()
		{
		}

		public virtual void Draw()
		{
		}
	}
}
