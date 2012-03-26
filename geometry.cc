#include "adventure.h"

Vector::Vector(Vector *copy) : x(copy->x), y(copy->y) { }

Vector::Vector(float splat) : x(splat), y(splat) { }

Vector::Vector(float x, float y) : x(x), y(y) { }

float Vector::Length() const
{
	return sqrtf(x * x + y * y);
}

float Vector::Normalize()
{
	float mag = Length();

	if(mag != 0.0)
	{
		x /= mag;
		y /= mag;
	}

	return mag;
}

float Vector::Dot(const Vector &v2) const
{
	return (x * v2.x) + (y * v2.y);
}

Vector Vector::Zero()
{
	return Vector(0, 0);
}

float Vector::Distance(const Vector& v1, const Vector& v2)
{
	return sqrtf(pow((v2.x - v1.x), 2) + pow((v2.y - v1.y), 2));
}

Vector& Vector::operator= (const Vector& v2)
{
	if (this == &v2)
		return *this;

	x = v2.x;
	y = v2.y;

	return *this;
}

Vector& Vector::operator+= (const Vector& v2)
{
	x += v2.x;
	y += v2.y;

	return *this;
}

Vector& Vector::operator-= (const Vector& v2)
{
	x -= v2.x;
	y -= v2.y;

	return *this;
}

Vector& Vector::operator*= (const float scalar)
{
	x *= scalar;
	y *= scalar;

	return *this;
}

Vector& Vector::operator/= (const float scalar)
{
	x /= scalar;
	y /= scalar;

	return *this;
}

const Vector Vector::operator+(const Vector &v2) const
{
	return Vector(*this) += v2;
}

const Vector Vector::operator-(const Vector &v2) const
{
	return Vector(*this) -= v2;
}

const Vector Vector::operator*(const float scalar) const
{
	return Vector(*this) *= scalar;
}

const Vector Vector::operator/(const float scalar) const
{
	return Vector(*this) /= scalar;
}

bool Vector::operator== (const Vector& v2) const
{
	return ((x == v2.x) && (y == v2.y));
}

bool Vector::operator!= (const Vector& v2) const
{
	return !((x == v2.x) && (y == v2.y));
}