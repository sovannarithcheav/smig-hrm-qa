function fn() {
    var env = karate.env || 'dev';

    var config = {
        env: env,
        changeManagementUrl: 'http://localhost:8083',
        notificationUrl:     'http://localhost:8088',
        paymentUrl:          'http://localhost:8085',
        userId:              '1',
        participantId:       '2',
    };

    if (env === 'staging') {
        config.changeManagementUrl = 'https://change-management.staging.smig.kh';
        config.notificationUrl     = 'https://notification.staging.smig.kh';
        config.paymentUrl          = 'https://payment.staging.smig.kh';
    }

    return config;
}
