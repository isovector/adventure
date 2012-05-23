#include "adventure.h"

Vector::Vector(const Vector &copy) : x(copy.x), y(copy.y) { }

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

const Vector Vector::operator/(const Vector& v2) const
{
	return Vector(x / v2.x, y / v2.y);
}

bool Vector::operator== (const Vector& v2) const
{
	return ((x == v2.x) && (y == v2.y));
}

bool Vector::operator!= (const Vector& v2) const
{
	return !(*this == v2);
}



Rect::Rect(const Vector &p, const Vector &s) : pos(p), size(s) { }

Rect::Rect(float x, float y, float w, float h) : pos(Vector(x, y)), size(Vector(w, h)) { }

Rect::Rect(const Rect &copy) : pos(copy.pos), size(copy.size) { }


bool Rect::Contains(const Vector &point) const {
	return  pos.x < point.x
		&& pos.y < point.y
		&& pos.x + size.x > point.x
		&& pos.y + size.y > point.y;
}

bool Rect::Intersects(const Rect &other) const {
	return !(pos.x > other.pos.x + other.size.x
			|| other.pos.x > pos.x + size.x
			|| pos.y > other.pos.y + other.size.y
			|| other.pos.y > pos.y + size.y);
}

bool Rect::operator== (const Rect &r2) const {
	return pos == r2.pos && size == r2.size;
}

bool Rect::operator!= (const Rect &r2) const { 
	return !(*this == r2);
}
