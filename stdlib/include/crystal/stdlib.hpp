#pragma once

#include <cstdint>

#ifndef CPPIZE_NO_RTTI
  #include <typeinfo>
#endif

namespace Crystal
{
  #ifndef CPPIZE_NO_RTTI
  class Type;

  #endif // CPPIZE_NO_RTTI

  class Object
  {
  public:
  #ifndef CPPIZE_NO_RTTI
    virtual Type get_type();
  #endif

    virtual const char* to_s();
  };

  #ifndef CPPIZE_NO_RTTI
  class Type : public Object
  {
  public:
    const char* name() // Todo : use crystal strings
    {
      return info->name();
    }

    Type(const std::type_info *t):info(t)
    {
    }
  private:
    const std::type_info *info;
  };

  Type Object::get_type()
  {
    return Type(&typeid(*this));
  }
  #endif // CPPIZE_NO_RTTI

  const char* Object::to_s()
  {
    #ifdef CPPIZE_NO_RTTI
      return "Crystal::Object";
    #else
      return get_type().name();
    #endif // CPPIZE_NO_RTTI
  }

  #ifdef CPPIZE_USE_PRIMITIVE_TYPES
    template<typename T = int> 
    using Numeric<T> = T;
  #else
    template<typename T = int>
    class Numeric : public Object
    { 
    public:
      Numeric(T data)
      {
        storage = data;
      }

      Numeric<T>& operator=(Numeric<T> data)
      {
        return storage = data.storage;
      }

      Numeric<T>& operator=(T data)
      {
        return storage = data;
      }

      bool operator ==(T data)
      {
        return data == storage;
      }

      bool operator !=(T data)
      {
        return data != storage;
      }

      bool operator >(T data)
      {
        return storage > data;
      }

      bool operator <(T data)
      {
        return storage < data;
      }

      bool operator >=(T data)
      {
        return storage >= data;
      }

      bool operator <=(T data)
      {
        return storage <= data;
      }

      Numeric<T> operator +(T other)
      {
        Numeric<T>(storage + other);
      }

      Numeric<T> operator -(T other)
      {
        Numeric<T>(storage - other);
      }

      Numeric<T> operator *(T other)
      {
        Numeric<T>(storage * other);
      }

      Numeric<T> operator /(T other)
      {
        Numeric<T>(storage / other);
      }

      Numeric<T> operator %(T other)
      {
        Numeric<T>(storage % other);
      }

      Numeric<T> operator &(T other)
      {
        Numeric<T>(storage & other);
      }

      Numeric<T> operator |(T other)
      {
        Numeric<T>(storage | other);
      }

      Numeric<T> operator ^(T other)
      {
        Numeric<T> (storage ^ other);
      }

      operator T()
      {
        return storage;
      }

    protected:
      T storage;
    };

  #endif // CPPIZE_USE_PRIMITIVE_TYPES

  using Int = Numeric<signed int>;
  using Int8 = Numeric<std::int8_t>;
  using Int16 = Numeric<std::int16_t>;
  using Int32 = Numeric<std::int32_t>;
  using Int64 = Numeric<std::int64_t>;

  using UInt = Numeric<unsigned int>;
  using UInt8 = Numeric<std::uint8_t>;
  using UInt16 = Numeric<std::uint16_t>;
  using UInt32 = Numeric<std::uint32_t>; 
  using UInt64 = Numeric<std::uint64_t>;

  using Float = Numeric<double>;
  using Float32 = Numeric<float>;
  using Float64 = Numeric<double>;
  using LongFloat = Numeric<long double>;

  template<typename T>
  class Pointer : public Numeric<T*>
  {
  public:
    T& value()
    {
      return *(Numeric<T>::storage);
    }

    Pointer(T *value)
    {
      Numeric<T>::storage = value;
    }
  };

  template<typename T> inline Pointer<T> pointerof(T value)
  {
    return Pointer<T>(&value);
  }
}

#include <crystal/literals.hpp>