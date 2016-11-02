#pragma once

#ifndef CPPIZE_NO_RTTI
  #include <typeinfo>
#endif

namespace Crystal
{
  #ifndef CPPIZE_NO_RTTI
  class Type;
  #endif

  class Object
  {
  public:
  #ifndef CPPIZE_NO_RTTI
    Type get_type();
  #endif

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
  #endif


}