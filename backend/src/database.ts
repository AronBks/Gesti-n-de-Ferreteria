import { TypeOrmModuleAsyncOptions } from '@nestjs/typeorm';
import { ConfigService } from '@nestjs/config';

export const typeOrmAsyncConfig = (
  configService: ConfigService,
): TypeOrmModuleAsyncOptions => ({
  useFactory: async () => ({
    type: 'postgres',
    host: configService.get<string>('DB_HOST') || 'localhost',
    port: parseInt(configService.get<string>('DB_PORT') || '5432', 10),
    username: configService.get<string>('DB_USER') || configService.get<string>('DB_USERNAME') || 'postgres',
    password: configService.get<string>('DB_PASSWORD') || 'postgres',
    database: configService.get<string>('DB_NAME') || 'ferreteria_pos',
    entities: [__dirname + '/**/*.entity{.ts,.js}'],
    synchronize: false, // ← Desactivado nuevamente
    logging: false,
  }),
  inject: [ConfigService],
});
