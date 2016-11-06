#pragma once

Crystal::Int8 operator"" _cri8 (const unsigned long long int input){
  return Crystal::Int8((std::int8_t)input);
}

Crystal::Int16 operator"" _cri16 (const unsigned long long int input){
  return Crystal::Int16((std::int16_t)input);
}

Crystal::Int32 operator"" _cri32 (const unsigned long long int input){
  return Crystal::Int32((std::int32_t)input);
}

Crystal::Int64 operator"" _cri64 (const unsigned long long int input){
  return Crystal::Int64((std::int64_t)input);
}

Crystal::UInt8 operator"" _cru8 (const unsigned long long int input){
  return Crystal::UInt8((std::uint8_t)input);
}

Crystal::UInt16 operator"" _cru16 (const unsigned long long int input){
  return Crystal::UInt16((std::uint16_t)input);
}

Crystal::UInt32 operator"" _cru32 (const unsigned long long int input){
  return Crystal::UInt32((std::uint32_t)input);
}

Crystal::UInt64 operator"" _cru64 (const unsigned long long int input){
  return Crystal::UInt64((std::uint64_t)input);
}

Crystal::Float32 operator"" _crf32 (const long double input){
  return Crystal::Float32((float)input);
}

Crystal::Float64 operator"" _crf64 (const long double input){
  return Crystal::Float64((double)input);
}

Crystal::Bool operator""_crbool(const char t){
  return Crystal::Bool((const bool) t);
}

Crystal::String operator""_crstr(const char* c, size_t cnt)
{
  return Crystal::String(c,cnt);
}