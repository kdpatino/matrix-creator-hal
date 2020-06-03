#include "cpp/driver/microphone_core.h"

#include <unistd.h>

#include <iostream>
#include <string>
#include <valarray>

#include "cpp/driver/creator_memory_map.h"
#include "cpp/driver/microphone_array.h"
#include "cpp/driver/microphone_core_fir.h"

namespace matrix_hal {

MicrophoneCore::MicrophoneCore(MicrophoneArray &mics)
    : mics_(mics), is_FIR_activate_(true) {
  fir_coeff_.resize(kNumberFIRTaps);
}

MicrophoneCore::~MicrophoneCore() {}

void MicrophoneCore::Setup(MatrixIOBus *bus) {
  MatrixDriver::Setup(bus);
  SelectFIRCoeff(is_FIR_activate_);
}

bool MicrophoneCore::SetFIRCoeff() {
  return bus_->Write(kMicrophoneArrayBaseAddress,
                     reinterpret_cast<unsigned char *>(&fir_coeff_[0]),
                     fir_coeff_.size());
}

bool MicrophoneCore::SetCustomFIRCoeff(
    const std::valarray<int16_t> custom_fir) {
  if (custom_fir.size() == kNumberFIRTaps) {
    fir_coeff_ = custom_fir;
    return SetFIRCoeff();
  } else {
    std::cerr << "Size FIR Filter must be : " << kNumberFIRTaps << std::endl;
    return false;
  }
}

bool MicrophoneCore::SelectFIRCoeff(bool activate_compensation_filter) {
  is_FIR_activate_ = activate_compensation_filter;

  if (is_FIR_activate_) {
    fir_coeff_ = FIR_default;
  } else {
    fir_coeff_ = without_filter;
  }
  return SetFIRCoeff();
}
};  // namespace matrix_hal
