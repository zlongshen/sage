

def is_MPolynomial(x):
    return isinstance(x, MPolynomial)

cdef class MPolynomial(CommutativeRingElement):

    ####################
    # Some standard conversions
    ####################
    def __int__(self):
        if self.degree() == 0:
            return int(self.constant_coefficient())
        else:
            raise TypeError

    def __long__(self):
        if self.degree() == 0:
            return long(self.constant_coefficient())
        else:
            raise TypeError

    def __float__(self):
        if self.degree() == 0:
            return float(self.constant_coefficient())
        else:
            raise TypeError

    def _mpfr_(self, R):
        if self.degree() == 0:
            return R(self.constant_coefficient())
        else:
            raise TypeError

    def _complex_mpfr_field_(self, R):
        if self.degree() == 0:
            return R(self.constant_coefficient())
        else:
            raise TypeError

    def _complex_double_(self, R):
        if self.degree() == 0:
            return R(self.constant_coefficient())
        else:
            raise TypeError

    def _real_double_(self, R):
        if self.degree() == 0:
            return R(self.constant_coefficient())
        else:
            raise TypeError

    def _rational_(self):
        if self.degree() == 0:
            from sage.rings.rational import Rational
            return Rational(repr(self))
        else:
            raise TypeError

    def _integer_(self):
        if self.degree() == 0:
            from sage.rings.integer import Integer
            return Integer(repr(self))
        else:
            raise TypeError


    def polynomial(self, var):
        """
        Let var be one of the variables of the parent of self.  This
        returns self viewed as a unvariate polynomial in var over the
        polynomial ring generated by all the other variables of the parent.

        EXAMPLES:
            sage: R.<x,w,z> = QQ[]
            sage: f = x^3 + 3*w*x + w^5 + (17*w^3)*x + z^5
            sage: f.polynomial(x)
            x^3 + (17*w^3 + 3*w)*x + w^5 + z^5
            sage: parent(f.polynomial(x))
            Univariate Polynomial Ring in x over Polynomial Ring in w, z over Rational Field

            sage: f.polynomial(w)
            w^5 + 17*x*w^3 + 3*x*w + z^5 + x^3
            sage: f.polynomial(z)
            z^5 + w^5 + 17*x*w^3 + x^3 + 3*x*w
            sage: R.<x,w,z,k> = ZZ[]
            sage: f = x^3 + 3*w*x + w^5 + (17*w^3)*x + z^5 +x*w*z*k + 5
            sage: f.polynomial(x)
            x^3 + (17*w^3 + w*z*k + 3*w)*x + w^5 + z^5 + 5
            sage: f.polynomial(w)
            w^5 + 17*x*w^3 + (x*z*k + 3*x)*w + z^5 + x^3 + 5
            sage: f.polynomial(z)
            z^5 + x*w*k*z + w^5 + 17*x*w^3 + x^3 + 3*x*w + 5
            sage: f.polynomial(k)
            x*w*z*k + w^5 + z^5 + 17*x*w^3 + x^3 + 3*x*w + 5
        """
        cdef int ind
        R = self.parent()
        G = R.gens()
        Z = list(G)
        try:
            ind = Z.index(var)
        except ValueError:
            raise ValueError, "var must be one of the generators of the parent polynomial ring."

        if R.ngens() <= 1:
            return self.univariate_polynomial()

        other_vars = Z
        del other_vars[ind]

        # Make polynomial ring over all variables except var.
        S = R.base_ring()[tuple(other_vars)]
        ring = S[var]

        d = self.degree(var)
        B = ring.base_ring()
        w = dict([(remove_from_tuple(e, ind), val) for e, val in self.dict().iteritems() if not e[ind]])
        v = [B(w)]  # coefficients that don't involve var
        z = var
        for i in range(1,d+1):
            c = self.coefficient(z).dict()
            w = dict([(remove_from_tuple(e, ind), val) for e, val in c.iteritems()])
            v.append(B(w))
            z *= var
        return ring(v)

cdef remove_from_tuple(e, int ind):
    w = list(e)
    del w[ind]
    return tuple(w)
