env = process.env.NODE_ENV or 'development'

module.exports = switch env

    when 'development'

        'pass'

    when 'production'

        'pass'
