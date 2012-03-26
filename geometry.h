#ifndef ADVENTURE_GEOMETRY_H
#define ADVENTURE_GEOMETRY_H

#include <math.h>

class Vector {
    public:
        float x, y;    
    
        Vector(float x, float y);
        Vector(float splat = 0.0f);
        Vector(Vector *copy); 
        ~Vector() { };

        float Length() const;
        float Normalize();
        float Dot(const Vector& v2) const;

        static Vector Zero();
        static float Distance(const Vector& v1, const Vector& v2);

        Vector& operator= (const Vector& v2);

        Vector& operator+= (const Vector& v2);
        Vector& operator-= (const Vector& v2);
        Vector& operator*= (const float scalar);
        Vector& operator/= (const float scalar);

        const Vector operator+(const Vector &v2) const;
        const Vector operator-(const Vector &v2) const;
        const Vector operator*(const float scalar) const;
        const Vector operator/(const float scalar) const;

        bool operator== (const Vector& v2) const;
        bool operator!= (const Vector& v2) const;
};

#endif
