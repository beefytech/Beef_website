using Beefy.widgets;
using Beefy.theme.dark;
using Beefy.gfx;
using System;

namespace BIStubUI
{
	public class EulaScrollbar : Scrollbar
	{
	    public class DarkThumb : Scrollbar.Thumb
	    {               
	        public override void Draw(Graphics g)
	        {
	            base.Draw(g);
	            using (g.PushColor(0x80000000))
					g.FillRect(0, 0, mWidth, mHeight);
	        }
	    }

	    
	    public this()
	    {
	        mBaseSize = DarkTheme.sUnitSize - 1;
	        mDualBarSizeOffset = -2;

	        mThumb = new DarkThumb();
	        mThumb.mScrollbar = this;
	        AddWidget(mThumb);
	    }

		public override void RehupScale(float oldScale, float newScale)
		{
			mBaseSize = DarkTheme.sUnitSize - 1;
			base.RehupScale(oldScale, newScale);
		}

	    public override void Draw(Graphics g)
	    {
	        base.Draw(g);

	        using (g.PushColor(0x10000000))
				g.FillRect(0, 0, mWidth, mHeight);
	    }

		public override void DrawAll(Graphics g)
		{
			if ((mWidth <= 0) || (mHeight <= 0))
				return;

			base.DrawAll(g);
		}

	    public override double GetContentPosAt(float x, float y)
	    {
	        float btnMargin = 0;
	        float sizeLeft = (mOrientation == Orientation.Horz) ? (mWidth - btnMargin * 2) : (mHeight - btnMargin * 2);

	        if (mOrientation == Orientation.Horz)
	        {                
	            float trackSize = sizeLeft - mThumb.mWidth;
	            float trackPct = (x - btnMargin) / trackSize;
	            double contentPos = (mContentSize - mPageSize) * trackPct;
	            return contentPos;
	        }
	        else
	        {
	            float trackSize = sizeLeft - mThumb.mHeight;
	            float trackPct = (y - btnMargin) / trackSize;
	            double contentPos = (mContentSize - mPageSize) * trackPct;
	            return contentPos;
	        }
	    }

	    public override void ResizeContent()
	    {
	        float btnMargin = 0;

	        float sizeLeft = (mOrientation == Orientation.Horz) ? (mWidth - btnMargin * 2) : (mHeight - btnMargin * 2);

	        if ((mPageSize < mContentSize) && (mContentSize > 0))
	        {
	            double pagePct = mPageSize / mContentSize;
	            mThumb.mVisible = true;

				double thumbSize = Math.Max(Math.Round(Math.Min(sizeLeft, Math.Max(GS!(12), sizeLeft * pagePct))), 0);
				double trackSize = Math.Max(sizeLeft - ((thumbSize) - (sizeLeft * pagePct)), 0);
				if (mOrientation == Orientation.Horz)
				    mThumb.Resize((float)(btnMargin + (float)Math.Round(mContentPos / mContentSize * trackSize)), 0, (float)thumbSize, mBaseSize);
				else
				    mThumb.Resize(0, (float)(btnMargin + (float)Math.Round(mContentPos / mContentSize * trackSize)), mBaseSize, (float)thumbSize);
	        }
	        else
	        {
	            mThumb.mVisible = false;
	        }
	    }

	    public override void Resize(float x, float y, float width, float height)
	    {
	        base.Resize(x, y, width, height);

	        ResizeContent();
	    }
	}

	class EulaEditWidgetContent : DarkEditWidgetContent
	{
		
	}

	class EulaEditWidget : DarkEditWidget
	{
		public this() : base(new EulaEditWidgetContent())
		{
			let editWidgetContent = (EulaEditWidgetContent)mEditWidgetContent;
			editWidgetContent.SetFont(gApp.mEULAFont, false, false);
			mDrawBox = false;

			editWidgetContent.mTextColors[0] = 0xFF000000;
			editWidgetContent.mIsMultiline = true;
			editWidgetContent.mWordWrap = true;
			editWidgetContent.mIsReadOnly = true;
			editWidgetContent.mAllowMaximalScroll = false;
			editWidgetContent.mHiliteColor = 0x30000000;

			mVertScrollbar = new EulaScrollbar();
			mVertScrollbar.mOrientation = .Vert;
			InitScrollbars(false, true);
		}

		public override void Draw(Graphics g)
		{
			base.Draw(g);

			using (g.PushColor(0x20000000))
				g.FillRect(0, 0, mWidth, mHeight);
			using (g.PushColor(0x80000000))
				g.OutlineRect(0, 0, mWidth, mHeight);
		}
	}
}
