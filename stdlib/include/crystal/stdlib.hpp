#pragma once

#if defined(CPPIZE_NO_RTTI) && !defined(CPPIZE_NO_RTTR)
  #define CPPIZE_NO_RTTR
#endif

#include <cstdint>

#ifndef CPPIZE_NO_RTTI
  #include <typeinfo>
#endif

#include <string>

/*#ifndef CPPIZE_NO_RTTR
  #include <cstddef>
  #include <crystal/reflection.hpp>
  
#endif*/

namespace Crystal
{
  #ifndef CPPIZE_NO_RTTI
  class Type;

  #endif // CPPIZE_NO_RTTI

  class String;

  class Object
  {
  public:
    using unsafe_type = void;
  #ifndef CPPIZE_NO_RTTI
    virtual Type get_type();
  #endif

    virtual String to_s();
  };

  #ifndef CPPIZE_NO_RTTI
  class Type : public Object
  {
  public:
    String name();
    

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

  

  #ifdef CPPIZE_USE_PRIMITIVE_TYPES
    template<typename T = int> 
    using Numeric<T> = T;
  #else
    template<typename T = int>
    class Numeric : public Object
    { 
    public:
      using unsafe_type = T;

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
        return Numeric<T>(storage + other);
      }

      Numeric<T> operator -(T other)
      {
        return Numeric<T>(storage - other);
      }

      Numeric<T> operator *(T other)
      {
        return Numeric<T>(storage * other);
      }

      Numeric<T> operator /(T other)
      {
        return Numeric<T>(storage / other);
      }

      Numeric<T> operator %(T other)
      {
        return Numeric<T>(storage % other);
      }

      Numeric<T> operator &(T other)
      {
        return Numeric<T>(storage & other);
      }

      Numeric<T> operator |(T other)
      {
        return Numeric<T>(storage | other);
      }

      Numeric<T> operator ^(T other)
      {
        return Numeric<T> (storage ^ other);
      }

      Numeric<T> operator -()
      {
        return Numeric<T>(-storage);
      }

      bool operator ==(Numeric<T> data)
      {
        return data.storage == storage;
      }

      bool operator !=(Numeric<T> data)
      {
        return data.storage != storage;
      }

      bool operator >(Numeric<T> data)
      {
        return storage > data.storage;
      }

      bool operator <(Numeric<T> data)
      {
        return storage < data.storage;
      }

      bool operator >=(Numeric<T> data)
      {
        return storage >= data.storage;
      }

      bool operator <=(Numeric<T> data)
      {
        return storage <= data.storage;
      }

      Numeric<T> operator +(Numeric<T> other)
      {
        return Numeric<T>(storage + other.storage);
      }

      Numeric<T> operator -(Numeric<T> other)
      {
        return Numeric<T>(storage - other.storage);
      }

      Numeric<T> operator *(Numeric<T> other)
      {
        return Numeric<T>(storage * other.storage);
      }

      Numeric<T> operator /(Numeric<T> other)
      {
        return Numeric<T>(storage / other.storage);
      }

      Numeric<T> operator %(Numeric<T> other)
      {
        return Numeric<T>(storage % other.storage);
      }

      Numeric<T> operator &(Numeric<T> other)
      {
        return Numeric<T>(storage & other.storage);
      }

      Numeric<T> operator |(Numeric<T> other)
      {
        return Numeric<T>(storage | other.storage);
      }

      Numeric<T> operator ^(Numeric<T> other)
      {
        return Numeric<T> (storage ^ other.storage);
      }

      operator T()
      {
        return storage;
      }

      operator bool()
      {
        return storage != 0;
      }

      String to_s();
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

  class Bool : public Object
  {
  public:
    Bool(bool b)
    {
      storage = b;
    }

    Bool(Bool& b)
    {
      storage = (bool)b;
    }

    operator bool()
    {
      return storage;
    }

    Bool operator !()
    {
      return Bool(!storage);
    }

    bool operator ==(Bool other)
    {
      return (bool)other == storage;
    }

    bool operator !=(Bool other)
    {
      return (bool)other != storage;
    }
  private:
    bool storage;
  };

  template<typename T>
  using _basic_string = std::basic_string<T>;

  class String : public Object, public _basic_string<char>
  {
  public:
    String(const char* c) : _basic_string<char>(c){}
    String(const char* c, size_t len) : _basic_string<char>(c,len){}
    String(char *c) : _basic_string<char>(c){}
    String(char *c, size_t len) :_basic_string<char>(c,len){}

    Bool is_empty()
    {
      return Bool(size() == 0);
    }
  };

  String Object::to_s()
  {
    #ifdef CPPIZE_NO_RTTI
      return "Crystal::Object";
    #else
      return get_type().name();
    #endif // CPPIZE_NO_RTTI
  }


  #ifndef CPPIZE_NO_RTTI
    String Type::name()
    {
      return String(info->name());
    }

  #endif   

  #ifndef CPPIZE_USE_PRIMITIVE_TYPES
    template<typename T>
    String Numeric<T>::to_s()
    {
      return String(storage);
    }
  #endif
}

#include <crystal/literals.hpp>