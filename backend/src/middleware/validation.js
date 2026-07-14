const { validationResult } = require('express-validator');

const validate = (validations) => {
  return async (req, res, next) => {
    const validationArray = Array.isArray(validations) ? validations : [validations];
    
    await Promise.all(validationArray.map(validation => validation.run(req)));

    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }

    return res.status(400).json({
      success: false,
      message: 'Validation failed',
      errors: errors.array().map(err => ({
        field: err.param,
        message: err.msg,
      })),
    });
  };
};

module.exports = { validate };