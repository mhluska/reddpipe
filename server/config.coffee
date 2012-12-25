env = process.env.NODE_ENV or 'development'

module.exports = switch env

    when 'development'

        namespace: ''

    when 'production'

        namespace: '/demo/pipeline-new'
