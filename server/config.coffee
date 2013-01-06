env = process.env.NODE_ENV or 'development'

module.exports = switch env

    when 'development'

        redisPort: 6379

    when 'production'

        redisPort: 6380
