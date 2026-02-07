#include <iostream>
#include <cmath>

extern "C" {
    
    // Basic arithmetic functions
    double add(double a, double b) {
        return a + b;
    }
    
    double subtract(double a, double b) {
        return a - b;
    }
    
    double multiply(double a, double b) {
        return a * b;
    }
    
    double divide(double a, double b) {
        if(b == 0) {
            std::cerr << "Error: Division by zero";
            return NAN;
        }
        return a / b;
    }

    // Trigonometric functions
    double sin_deg(double degrees) {
        return sin(degrees * M_PI / 180.0);
    }
    
    double cos_deg(double degrees) {
        return cos(degrees * M_PI / 180.0);
    }
    
    double tan_deg(double degrees) {
        return tan(degrees * M_PI / 180.0);
    }
    
    // Logarithmic functions
    double log_base_10(double x) {
        if(x <= 0) {
            std::cerr << "Error: Non-positive input for logarithm";
            return NAN;
        }
        return log10(x);
    }
    
    double natural_log(double x) {
        if(x <= 0) {
            std::cerr << "Error: Non-positive input for logarithm";
            return NAN;
        }
        return log(x);
    }
    
    // Financial calculations
    double future_value(double principal, double rate, double time) {
        return principal * pow((1 + rate), time);
    }
    
    double present_value(double future_value, double rate, double time) {
        return future_value / pow((1 + rate), time);
    }
}