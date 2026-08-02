import { Injectable, OnApplicationBootstrap, Logger } from '@nestjs/common';
import { DataSource } from 'typeorm';
import * as fs from 'fs';
import * as path from 'path';

@Injectable()
export class SeedService implements OnApplicationBootstrap {
  private readonly logger = new Logger(SeedService.name);

  // Hash bcrypt de la contraseña simple "123"
  private readonly TEST_PASSWORD_HASH = '$2b$10$zfbtxCRBKTzqHFVahszZ6.eTBgql.h46hoopvUbgQrsV.qieee1Em';

  constructor(private readonly dataSource: DataSource) {}

  async onApplicationBootstrap() {
    try {
      this.logger.log('🔍 Verificando estado de la base de datos...');
      const hasUsers = await this.checkIfUsersExist();

      if (!hasUsers) {
        this.logger.log('🌱 Base de datos vacía detectada. Iniciando siembra automática de datos...');
        await this.runSeeds();
        this.logger.log('✅ Siembra de datos completada exitosamente.');
      } else {
        this.logger.log('✅ Base de datos previamente inicializada.');
        // Asegurar que las contraseñas de prueba sean "123"
        await this.syncTestPasswords();
      }
    } catch (error) {
      this.logger.error('⚠️ Error al verificar/sembrar base de datos:', error.message);
    }
  }

  private async checkIfUsersExist(): Promise<boolean> {
    try {
      const result = await this.dataSource.query(
        "SELECT COUNT(*) FROM information_schema.tables WHERE table_name = 'usuarios'"
      );
      const tableExists = parseInt(result[0]?.count || '0', 10) > 0;

      if (!tableExists) return false;

      const userCount = await this.dataSource.query('SELECT COUNT(*) FROM usuarios');
      return parseInt(userCount[0]?.count || '0', 10) > 0;
    } catch {
      return false;
    }
  }

  private async syncTestPasswords() {
    try {
      await this.dataSource.query(
        `UPDATE usuarios 
         SET contrasena_hash = $1, estado = 'ACTIVO', activo = true 
         WHERE email IN ('admin@ferreteria.com', 'gerente@ferreteria.com', 'vendedor@ferreteria.com', 'almacen@ferreteria.com')`,
        [this.TEST_PASSWORD_HASH]
      );
      this.logger.log('🔑 Contraseñas de usuarios de prueba estandarizadas a "123".');
    } catch (err) {
      this.logger.warn('⚠️ No se pudo actualizar contraseñas de prueba:', err.message);
    }
  }

  private async runSeeds() {
    const seedFiles = ['01_schema.sql', '02_views.sql', '03_functions.sql', '04_seed_data.sql'];
    const possiblePaths = [
      path.join(process.cwd(), 'database', 'init'),
      path.join(process.cwd(), '..', 'database', 'init'),
      '/docker-entrypoint-initdb.d',
    ];

    let seedDir = '';
    for (const dir of possiblePaths) {
      if (fs.existsSync(dir) && fs.existsSync(path.join(dir, '01_schema.sql'))) {
        seedDir = dir;
        break;
      }
    }

    if (!seedDir) {
      this.logger.warn('⚠️ No se encontró la carpeta database/init para ejecutar scripts SQL.');
      return;
    }

    for (const file of seedFiles) {
      const filePath = path.join(seedDir, file);
      if (fs.existsSync(filePath)) {
        this.logger.log(`📄 Ejecutando script SQL: ${file}`);
        const sql = fs.readFileSync(filePath, 'utf-8');
        await this.dataSource.query(sql);
      }
    }
  }
}
