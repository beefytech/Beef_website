using System;
using System.Diagnostics;

namespace NBody
{
	class Program
	{
		public static void Main(String[] args)
		{
			Stopwatch sw = scope .();
			sw.Start();

			int32 n =args.Count> 0 ? Int32.Parse(args[0]) : 10000;
			NBodySystem bodies = scope NBodySystem();
			Console.WriteLine("{0:f9}", bodies.Energy());
			for (int i = 0; i < n; i++) bodies.Advance(0.01);
			Console.WriteLine("{0:f9}", bodies.Energy());

			sw.Stop();
			Console.WriteLine("Time: {}", sw.ElapsedMilliseconds);
		}
	}
}

[CRepr]
struct Body
{
	public double[3] x;
	public double[3] v;
	public double mass;

	public this(double mass)
	{
		this = default;
		this.mass = mass;
	}

	public this(double x, double y, double z, double vx, double vy, double vz, double mass)
	{
		this.x[0] = x;
		this.x[1] = y;
		this.x[2] = z;
		this.v[0] = vx;
		this.v[1] = vy;
		this.v[2] = vz;
		this.mass = mass;
	}

}
struct Pair { public Body* bi , bj; }

class NBodySystem
{
	private Body[] bodies ~ delete _;
	private Pair[] pairs ~ delete _;

	const double Pi = 3.141592653589793;
	const double Solarmass = 4 * Pi * Pi;
	const double DaysPeryear = 365.24;

	public this()
	{
		bodies = new Body[]
		(
			Body( 
		// // Sun
			    Solarmass
			),
			Body( // Jupiter
			    4.84143144246472090e+00,
			    -1.16032004402742839e+00,
			    -1.03622044471123109e-01,
			    1.66007664274403694e-03 * DaysPeryear,
			    7.69901118419740425e-03 * DaysPeryear,
			    -6.90460016972063023e-05 * DaysPeryear,
			    9.54791938424326609e-04 * Solarmass
			),
			Body(
				// // Saturn
			    8.34336671824457987e+00,
			    4.12479856412430479e+00,
			    -4.03523417114321381e-01,
			    -2.76742510726862411e-03 * DaysPeryear,
			    4.99852801234917238e-03 * DaysPeryear,
			    2.30417297573763929e-05 * DaysPeryear,
			    2.85885980666130812e-04 * Solarmass
			),
			Body(
				// // Uranus
			    1.28943695621391310e+01,
			    -1.51111514016986312e+01,
			    -2.23307578892655734e-01,
			    2.96460137564761618e-03 * DaysPeryear,
			    2.37847173959480950e-03 * DaysPeryear,
			    -2.96589568540237556e-05 * DaysPeryear,
			    4.36624404335156298e-05 * Solarmass
			),
			Body(
				// // Neptune
			    1.53796971148509165e+01,
			    -2.59193146099879641e+01,
			    1.79258772950371181e-01,
			    2.68067772490389322e-03 * DaysPeryear,
			    1.62824170038242295e-03 * DaysPeryear,
			    -9.51592254519715870e-05 * DaysPeryear,
			    5.15138902046611451e-05 * Solarmass
			)
		);

		pairs = new Pair[bodies.Count * (bodies.Count - 1) / 2];
		int pi = 0;
		for (int i = 0; i < bodies.Count - 1; i++)
			for (int j = i + 1; j < bodies.Count; j++)
			{
				pairs[pi].bi = &bodies[i];
				pairs[pi++].bj = &bodies[j];
			}

		double px = 0.0, py = 0.0, pz = 0.0;
		for (var b in ref bodies)
		{
			px += b.v[0] * b.mass; py += b.v[1] * b.mass; pz += b.v[2] * b.mass;
		}
		var sol = ref bodies[0];
		sol.v[0] = -px / Solarmass; sol.v[1] = -py / Solarmass; sol.v[2] = -pz / Solarmass;
	}

	[CLink]
	public static extern double sqrt(double f);

	public void Advance(double dt)
	{
		double[3] d;
		Body* a;

		int count = bodies.Count;

		a = &bodies[0];
		for (int i < count)
		{
			Body* b = a + 1;
			for (int j = i + 1; j < count; j++)
			{
				d[0] = a.x[0] - b .x[0];
				d[1] = a.x[1] - b.x[1];
				d[2] = a.x[2] - b.x[2];

				double d2 = d[0] * d[0] + d[1] * d[1] + d[2] * d[2];
				double mag = dt / (d2 * sqrt(d2));

				a.v[0] -= d[0] * b.mass * mag;
				a.v[1] -= d[1] * b.mass * mag;
				a.v[2] -= d[2] * b.mass * mag;

				b.v[0] += d[0] * a.mass * mag;
				b.v[1] += d[1] * a.mass * mag;
				b.v[2] += d[2] * a.mass * mag;
				b++;
			}
			a++;
		}

		a = &bodies[0];
		for (int i < bodies.Count)
		{
			a.x[0] += dt * a.v[0]; a.x[1] += dt * a.v[1]; a.x[2] += dt * a.v[2];
			a++;
		}
	}

	public void Advance2(double dt)
	{
		for (var p in pairs)
		{
			Body* bi = p.bi, bj = p.bj;
			double dx = bi.x[0] - bj.x[0], dy = bi.x[1] - bj.x[1], dz = bi.x[2] - bj.x[2];
			double d2 = dx * dx + dy * dy + dz * dz;
			double mag = dt / (d2 * Math.Sqrt(d2));
			bi.v[0] -= dx * bj.mass * mag; bj.v[0] += dx * bi.mass * mag;
			bi.v[1] -= dy * bj.mass * mag; bj.v[1] += dy * bi.mass * mag;
			bi.v[2] -= dz * bj.mass * mag; bj.v[2] += dz * bi.mass * mag;
		}
		for (var b in ref bodies)
		{
			b.x[0] += dt * b.v[0]; b.x[1] += dt * b.v[1]; b.x[2] += dt * b.v[2];
		}
	}

	public double Energy()
	{
		double e = 0.0;
		for (int i = 0; i < bodies.Count; i++)
		{
			var bi = ref bodies[i];
			e += 0.5 * bi.mass * (bi.v[0] * bi.v[0] + bi.v[1] * bi.v[1] + bi.v[2] * bi.v[2]);
			for (int j = i + 1; j < bodies.Count; j++)
			{
				var bj = ref bodies[j];
				double dx = bi.x[0] - bj.x[0], dy = bi.x[1] - bj.x[1], dz = bi.x[2] - bj.x[2];
				e -= (bi.mass * bj.mass) / Math.Sqrt(dx * dx + dy * dy + dz * dz);
			}
		}
		return e;
	}
}