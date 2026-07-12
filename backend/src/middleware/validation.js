const { validationResult } = require('express-validator');

const validate = (validations) => {
  return async (req, res, next) => {
    try {
      // If validations is not an array, convert to array
      const validationArray = Array.isArray(validations) ? validations : [validations];
      
      // Run all validations
      await Promise.all(validationArray.map(validation => validation.run(req)));

      const errors = validationResult(req);
      if (errors.isEmpty()) {
        return next();
      }

      // Format errors
      const formattedErrors = errors.array().map(err => ({
        field: err.param || err.path,
        message: err.msg,
      }));

      return res.status(400).json({
        success: false,
        message: 'Validation failed',
        errors: formattedErrors,
      });
    } catch (error) {
      console.error('Validation middleware error:', error);
      // If validation fails, still try to process the request
      next();
    }
  };
};

module.exports = { validate };