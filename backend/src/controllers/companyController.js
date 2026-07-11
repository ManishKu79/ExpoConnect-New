const Company = require('../models/Company');
const User = require('../models/User');
const uploadService = require('../services/uploadService');
const logger = require('../utils/logger');

exports.createCompany = async (req, res, next) => {
  try {
    const {
      name,
      description,
      website,
      industry,
      size,
      foundedYear,
      headquarters,
      socialLinks,
    } = req.body;

    // Check if company already exists
    const existingCompany = await Company.findOne({ name });
    if (existingCompany) {
      return res.status(400).json({
        success: false,
        message: 'Company with this name already exists',
      });
    }

    const company = await Company.create({
      name,
      description,
      website,
      industry,
      size,
      foundedYear,
      headquarters,
      socialLinks,
    });

    // If user is creating company, assign it to their profile
    if (req.user) {
      req.user.company = company._id;
      await req.user.save();
    }

    res.status(201).json({
      success: true,
      message: 'Company created successfully',
      data: company,
    });
  } catch (error) {
    logger.error(`Create company error: ${error.message}`);
    next(error);
  }
};

exports.getAllCompanies = async (req, res, next) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const query = {};
    if (req.query.industry) query.industry = req.query.industry;
    if (req.query.isVerified !== undefined) query.isVerified = req.query.isVerified === 'true';
    if (req.query.search) {
      query.$text = { $search: req.query.search };
    }

    const companies = await Company.find(query)
      .skip(skip)
      .limit(limit)
      .sort({ reputationScore: -1, createdAt: -1 });

    const total = await Company.countDocuments(query);

    res.status(200).json({
      success: true,
      data: companies,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    logger.error(`Get all companies error: ${error.message}`);
    next(error);
  }
};

exports.getCompanyById = async (req, res, next) => {
  try {
    const company = await Company.findById(req.params.id);
    if (!company) {
      return res.status(404).json({
        success: false,
        message: 'Company not found',
      });
    }

    res.status(200).json({
      success: true,
      data: company,
    });
  } catch (error) {
    logger.error(`Get company by id error: ${error.message}`);
    next(error);
  }
};

exports.updateCompany = async (req, res, next) => {
  try {
    const company = await Company.findById(req.params.id);
    if (!company) {
      return res.status(404).json({
        success: false,
        message: 'Company not found',
      });
    }

    // Check if user owns this company or is admin
    const user = await User.findById(req.user._id);
    if (
      user.company?.toString() !== company._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this company',
      });
    }

    const updates = req.body;
    Object.keys(updates).forEach(key => {
      company[key] = updates[key];
    });

    await company.save();

    res.status(200).json({
      success: true,
      message: 'Company updated successfully',
      data: company,
    });
  } catch (error) {
    logger.error(`Update company error: ${error.message}`);
    next(error);
  }
};

exports.uploadLogo = async (req, res, next) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Logo file is required',
      });
    }

    const company = await Company.findById(req.params.id);
    if (!company) {
      return res.status(404).json({
        success: false,
        message: 'Company not found',
      });
    }

    // Check ownership
    const user = await User.findById(req.user._id);
    if (
      user.company?.toString() !== company._id.toString() &&
      req.user.role !== 'admin'
    ) {
      return res.status(403).json({
        success: false,
        message: 'You do not have permission to update this company',
      });
    }

    // Delete old logo if exists
    if (company.logo) {
      try {
        const publicId = company.logo.split('/').pop().split('.')[0];
        await uploadService.deleteFromCloudinary(`expoconnect/companies/${publicId}`);
      } catch (error) {
        logger.warn(`Failed to delete old logo: ${error.message}`);
      }
    }

    const uploadResult = await uploadService.uploadToCloudinary(req.file.buffer, {
      folder: 'expoconnect/companies',
      transformation: [
        { width: 300, height: 300, crop: 'limit' },
      ],
    });

    company.logo = uploadResult.url;
    await company.save();

    res.status(200).json({
      success: true,
      message: 'Company logo updated successfully',
      data: { logo: company.logo },
    });
  } catch (error) {
    logger.error(`Upload logo error: ${error.message}`);
    next(error);
  }
};

exports.deleteCompany = async (req, res, next) => {
  try {
    const company = await Company.findById(req.params.id);
    if (!company) {
      return res.status(404).json({
        success: false,
        message: 'Company not found',
      });
    }

    // Only admin can delete companies
    if (req.user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Only administrators can delete companies',
      });
    }

    await company.remove();

    res.status(200).json({
      success: true,
      message: 'Company deleted successfully',
    });
  } catch (error) {
    logger.error(`Delete company error: ${error.message}`);
    next(error);
  }
};